/* Definitions for AMD x86-64 running Linux-based GNU systems with ELF format.
   Copyright (C) 2001, 2002 Free Software Foundation, Inc.
   Contributed by Jan Hubicka <jh@suse.cz>, based on linux.h.

This file is part of GCC.

GCC is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2, or (at your option)
any later version.

GCC is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with GCC; see the file COPYING.  If not, write to
the Free Software Foundation, 59 Temple Place - Suite 330,
Boston, MA 02111-1307, USA.  */

#define TARGET_VERSION fprintf (stderr, " (x86-64 Linux/ELF)");

#define TARGET_OS_CPP_BUILTINS()				\
  do								\
    {								\
	LINUX_TARGET_OS_CPP_BUILTINS();				\
	if (flag_pic)						\
	  {							\
	    builtin_define ("__PIC__");				\
	    builtin_define ("__pic__");				\
	  }							\
    }								\
  while (0)

#undef CPP_SPEC
#define CPP_SPEC "%{posix:-D_POSIX_SOURCE} %{pthread:-D_REENTRANT}"

/* The svr4 ABI for the i386 says that records and unions are returned
   in memory.  In the 64bit compilation we will turn this flag off in
   override_options, as we never do pcc_struct_return scheme on this target.  */
#undef DEFAULT_PCC_STRUCT_RETURN
#define DEFAULT_PCC_STRUCT_RETURN 1

/* We arrange for the whole %fs segment to map the tls area.  */
#undef TARGET_TLS_DIRECT_SEG_REFS_DEFAULT
#define TARGET_TLS_DIRECT_SEG_REFS_DEFAULT MASK_TLS_DIRECT_SEG_REFS

/* Provide a LINK_SPEC.  Here we provide support for the special GCC
   options -static and -shared, which allow us to link things in one
   of these three modes by applying the appropriate combinations of
   options at link-time.

   When the -shared link option is used a final link is not being
   done.  */

#undef	LINK_SPEC
#define LINK_SPEC "%{!m32:-m elf_x86_64} %{m32:-m elf_i386} \
  %{shared:-shared} \
  %{!shared: \
    %{!static: \
      %{rdynamic:-export-dynamic} \
      %{m32:%{!dynamic-linker:-dynamic-linker /lib/ld-linux.so.2}} \
      %{!m32:%{!dynamic-linker:-dynamic-linker /lib64/ld-linux-x86-64.so.2}}} \
    %{static:-static}}"

#define MULTILIB_DEFAULTS { "m64" }

#undef NEED_INDICATE_EXEC_STACK
#define NEED_INDICATE_EXEC_STACK 1

#define MD_UNWIND_SUPPORT "config/i386/linux-unwind.h"
