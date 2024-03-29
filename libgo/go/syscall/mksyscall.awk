# Copyright 2011 The Go Authors. All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.

# This AWK script reads a Go file with comments describing syscall
# functions and the C routines they map to.  It generates the Go code
# which calls the C routines.

# The syscall functins are marked by lines beginning with "//sys" and
# read like func declarations if //sys is replaced by func, but:
#	* The parameter lists must give a name for each argument.
#	  This includes return parameters.
#	* The parameter lists must give a type for each argument:
#	   the (x, y, z int) shorthand is not allowed.
#	* If the return parameter is an error, it must be named err.

# A line beginning with //sysnb is like //sys, except that the
# goroutine will not be suspended during the execution of the library
# call.  This must only be used for library calls which can never
# block, as otherwise the library call could cause all goroutines to
# hang.

# After the //sys or //sysnb line comes a second line which describes
# the C function.  The name must be the name of the function in the C
# library, and may be the same as the Go function.  The limitations on
# the argument list are the same as for the //sys line, but there must
# be at most one result parameter, and it must be given as just a
# type, without a name.

BEGIN {
    print "// This file was automatically generated by mksyscall.awk"
    print ""
    print "package syscall"
    print ""
    print "import \"unsafe\""
    print ""
    status = 0
}

/^\/\/sys/ {
    if ($1 == "//sysnb") {
	blocking = 0
    } else {
	blocking = 1
    }

    line = $0

    if (match(line, "//sys(nb)?[ 	]*[a-zA-Z0-9_]+\\([^()]*\\) *(\\(([^()]+)\\))?") == 0) {
	print "unmatched line:", $0 | "cat 1>&2"
	status = 1
	next
    }

    # Sets a[1] = //sysnb, a[2] == function name.
    split(line, a, "[ 	(]*")
    gofnname = a[2]

    off = match(line, "\\([^()]*\\)")
    end = index(substr(line, off, length(line) - off + 1), ")")
    gofnparams = substr(line, off + 1, end - 2)

    line = substr(line, off + end, length(line) - (off + end) + 1)
    off = match(line, "\\([^()]*\\)")
    if (off == 0) {
	gofnresults = ""
    } else {
	end = index(substr(line, off, length(line) - off + 1), ")")
	gofnresults = substr(line, off + 1, end - 2)
    }

    getline
    line = $0

    if (match(line, "//[a-zA-Z0-9_]+\\([^()]*\\)") == 0) {
	print "unmatched C line", $0, "after", gofnname | "cat 1>&2"
	status = 1
	next
    }

    split(line, a, "[ 	(]*")
    cfnname = substr(a[1], 3, length(a[1]) - 2)

    off = match(line, "\\([^()]*\\)")
    end = index(substr(line, off, length(line) - off + 1), ")")
    cfnparams = substr(line, off + 1, end - 2)

    line = substr(line, off + end + 1, length(line) - (off + end) + 1)
    while (substr(line, 1, 1) == " ") {
	line = substr(line, 2, length(line) - 1)
    }
    end = index(line, " ")
    if (end != 0) {
	line = substr(line, 1, end)
    }
    cfnresult = line

    printf("// Automatically generated wrapper for %s/%s\n", gofnname, cfnname)
    printf("//extern %s\n", cfnname)
    printf("func c_%s(%s) %s\n", cfnname, cfnparams, cfnresult)
    printf("func %s(%s) %s%s%s%s{\n",
	   gofnname, gofnparams, gofnresults == "" ? "" : "(", gofnresults,
	   gofnresults == "" ? "" : ")", gofnresults == "" ? "" : " ")

    loc = gofnname "/" cfnname ":"

    split(gofnparams, goargs, ", *")
    split(cfnparams, cargs, ", *")
    args = ""
    carg = 1
    for (goarg = 1; goargs[goarg] != ""; goarg++) {
	if (cargs[carg] == "") {
	    print loc, "not enough C parameters"
	}

	if (args != "") {
	    args = args ", "
	}

	if (split(goargs[goarg], a) != 2) {
	    print loc, "bad parameter:", goargs[goarg] | "cat 1>&2"
	    status = 1
	    next
	}

	goname = a[1]
	gotype = a[2]

	if (split(cargs[carg], a) != 2) {
	    print loc, "bad C parameter:", cargs[carg] | "cat 1>&2"
	    status = 1
	    next
	}

	ctype = a[2]

	if (gotype ~ /^\*/) {
	    if (gotype != ctype) {
		print loc, "Go/C pointer type mismatch:", gotype, ctype | "cat 1>&2"
		status = 1
		next
	    }
	    args = args goname
	} else if (gotype == "string") {
	    if (ctype != "*byte") {
		print loc, "Go string not matched to C *byte:", gotype, ctype | "cat 1>&2"
		status = 1
		next
	    }
	    printf("\t_p%d := StringBytePtr(%s)\n", goarg, goname)
	    args = sprintf("%s_p%d", args, goarg)
	} else if (gotype ~ /^\[\](.*)/) {
	    if (ctype !~ /^\*/ || cargs[carg + 1] == "") {
		print loc, "bad C type for slice:", gotype, ctype | "cat 1>&2"
		status = 1
		next
	    }

	    # Convert a slice into a pair of pointer, length.
	    # Don't try to take the address of the zeroth element of a
	    # nil slice.
	    printf("\tvar _p%d %s\n", goarg, ctype)
	    printf("\tif len(%s) > 0 {\n", goname)
	    printf("\t\t_p%d = (%s)(unsafe.Pointer(&%s[0]))\n", goarg, ctype, goname)
	    printf("\t} else {\n")
	    printf("\t\t_p%d = (%s)(unsafe.Pointer(&_zero))\n", goarg, ctype)
	    printf("\t}\n")

	    ++carg
	    if (split(cargs[carg], cparam) != 2) {
		print loc, "bad C parameter:", cargs[carg] | "cat 1>&2"
		status = 1
		next
	    }

	    args = sprintf("%s_p%d, %s(len(%s))", args, goarg, cparam[2], goname)
	} else if (gotype == "uintptr" && ctype ~ /^\*/) {
	    args = sprintf("%s(%s)(unsafe.Pointer(%s))", args, ctype, goname)
	} else {
	    args = sprintf("%s%s(%s)", args, ctype, goname)
	}

	carg++
    }

    if (cargs[carg] != "") {
	print loc, "too many C parameters" | "cat 1>&2"
	status = 1
	next
    }

    if (blocking) {
	print "\tentersyscall()"
    }

    printf("\t")
    if (gofnresults != "") {
	printf("_r := ")
    }
    printf("c_%s(%s)\n", cfnname, args)

    if (gofnresults != "") {
	fields = split(gofnresults, goresults, ", *")
	if (fields > 2) {
	    print loc, "too many Go results" | "cat 1>&2"
	    status = 1
	    next
	}
	usedr = 0
	for (goresult = 1; goresults[goresult] != ""; goresult++) {
	    if (split(goresults[goresult], goparam) != 2) {
		print loc, "bad result:", goresults[goresult] | "cat 1>&2"
		status = 1
		next
	    }

	    goname = goparam[1]
	    gotype = goparam[2]

	    if (goname == "err") {
		if (cfnresult ~ /^\*/) {
		    print "\tif _r == nil {"
		} else {
		    print "\tif _r < 0 {"
		}
		print "\t\terr = GetErrno()"
		print "\t}"
	    } else if (gotype == "uintptr" && cfnresult ~ /^\*/) {
		printf("\t%s = (%s)(unsafe.Pointer(_r))\n", goname, gotype)
	    } else {
		if (usedr) {
		    print loc, "two parameters but no errno parameter" | "cat 1>&2"
		    status = 1
		    next
		}
		printf("\t%s = (%s)(_r)\n", goname, gotype)
		usedr = 1
	    }
	}
    }

    if (blocking) {
	print "\texitsyscall()"
    }

    if (gofnresults != "") {
	print "\treturn"
    }

    print "}"

    print ""

    next
}

{ next }

END {
    if (status != 0) {
	print "*** mksyscall.awk failed" | "cat 1>&2"
	exit status
    }
}
