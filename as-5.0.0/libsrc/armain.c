/* armain.c */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "aslib.h"

static int creation_flag = 0;
static int verbose_level = 0;
static int verbose_action = 0;
#define VERBOSE_LEVEL
#include "common.c"



/* basenam:
 *  Strips path from the filename.
 */
static char *basenam(char *filename)
{
	char *p;

	p = strrchr(filename, '/');
	if (p != NULL)
		return p+1;

	return filename;
}



/* copycontents:
 *  Copy the contents from src to dst.
 */
static void copycontents(char *buffer, int buflen, FILE *src, FILE *dst)
{
	int len;
	while (fgets(buffer, buflen, src)) {
		len = strlen(buffer);
		if (len > 0) {
			if (buffer[len-1] == '\n')
				buffer[--len] = 0;
			if (len > 0) {
				if (buffer[--len] == '\r')
					buffer[len] = 0;
			}
		}
		fprintf(dst, "%s\n", buffer);
	}
}



/* create_archive:
 *  Creates an empty archive.
 */
static void create_archive(char *filename)
{
	FILE *libf;
	char *name;

	libf = fopen(filename, "w");
	if (!libf) {
		fprintf(stderr, "Error: cannot create '%s'.\n", filename);
		exit(1);
	}

	if (!creation_flag)
		fprintf(stderr, "Warning: '%s' did not exist.\n", filename);

	name = basenam(filename);
	fprintf(libf, "LIB %s\n", name);
	fprintf(libf, "END %s\n", name);
	fclose(libf);
}



/* name_in_list:
 *  Helper for finding whether a name is present in the list.
 */
static int name_in_list(char *name, struct lfile *list)
{
	while (list) {
		if (!strcmp(name, list->f_idp)) {
			list->f_found = 1;
			return 1;
		}
		list = list->f_flp;
	}

	return 0;
}



/* append:
 *  Appends members to an archive.
 */
static void append(char *arname, struct lfile *memberp)
{
	FILE *libf;
	char modname[NCPS];
	char line[FILSPC];
	int ret;

	verbose_action = 'a';

	libf = fopen(arname, "r+");
	if (!libf) {
		create_archive(arname);
		libf = fopen(arname, "r+");
	}
	if (!libf) {
		fprintf(stderr, "Error: cannot open '%s'.\n", arname);
		exit(1);
	}

	/* seek 'END' marker */
	while ((ret=getc(libf)) != 'E')
		if (ret == EOF || fgets(line, FILSPC, libf) == NULL) {
			fprintf(stderr, "Error: cannot seek 'END' marker.\n");
			exit(1);
		}

	fseek(libf, -1, SEEK_CUR);

	modname[0] = '\0';
	filep = memberp;
	cfp = NULL;

	while ((ret = as_getline())) {
		if (ret == 2) {
			if (*modname)
			fprintf(libf, "L1 %s\n", modname);

			strcpy(modname, basenam(cfp->f_idp));
			fprintf(libf, "L0 %s\n", modname);
		}

		fprintf(libf, "%s\n", ib);
	}

	fprintf(libf, "L1 %s\n", modname);
	fprintf(libf, "END %s\n", basenam(arname));
	fclose(libf);
}


/* replace:
 *  Adds members to an archive with replacement or deletes them.
 */
static void replace(char *arname, struct lfile *memberp, int delete)
{
	FILE * libf, *newf = NULL;
	char modname[NCPS];
	char newb[NINPUT];
	char c;
	int replaced;
	char tmpfile[FILSPC];

	verbose_action = 0;

	/* check that the archive exists */
	if ((libf = fopen(arname, "r"))) {
		fclose(libf);
	}
	else {
		if (delete) {
			fprintf(stderr, "Error: cannot open '%s'.\n", arname);
			exit(1);
		}
		create_archive(arname);
	}

	filep = new_lfile(arname);

	while (memberp) {
		if (!delete) {
			if (verbose_level)
				fprintf(stdout, "r - %s\n", memberp->f_idp);
			newf = fopen(memberp->f_idp, "r");
			if (!newf) {
				fprintf(stderr, "Error: cannot open '%s'.\n", memberp->f_idp);
				exit(1);
			}
		}
		else {
			if (verbose_level)
				fprintf(stdout, "d - %s\n", memberp->f_idp);
		}

		sprintf (tmpfile, "%s.tmp", arname);
		libf = fopen(tmpfile, "w");
		if (!libf) {
			fprintf(stderr, "Error: cannot create temporary file.\n");
			exit(1);
		}

		replaced = 0;
		cfp = NULL;

		while (as_getline()) {
			ip = ib;
			c = getnb();
			switch(c) {
			case 'L':
				c = getnb();
				if (c == '0') {
					getid(modname, -1);

					/* test whether the module name is the requested one */
					if (!strcmp(modname, memberp->f_idp)) {
						if (!delete) {
							fprintf(libf, "%s\n", ib);  /* L0 .. */

							/* copy the contents */
							copycontents(newb, NINPUT, newf, libf);

							replaced = 1;
						}

						while (as_getline()) {
							if (ib[1] == '1')
								break;
						}

						if (!delete)
							fprintf(libf, "%s\n", ib);   /* L1 .. */

						continue;
					}
				}

				fprintf(libf, "%s\n", ib);
				break;

			case 'E':
				if (!delete && !replaced) {
					strcpy(modname, basenam(memberp->f_idp));

					fprintf(libf, "L0 %s\n", modname);

					/* copy the contents */
					copycontents(newb, NINPUT, newf, libf);

					fprintf(libf, "L1 %s\n", modname);
					fprintf(libf, "END %s\n", basenam(arname));

					continue;
				}
				/* fall through ... */

			default:
				fprintf(libf, "%s\n", ib);
				break;
			}
		}

		fclose(libf);
		if (!delete)
			fclose(newf);

		/* replace existing archive by new one */
		remove(arname);
		rename(tmpfile, arname);

		memberp = memberp->f_flp;
	}
}



/* extract:
 *  Extracts members from an archive.
 */
static void extract(char *arname, struct lfile *memberp, int create)
{
	FILE *newf;
	char modname[NCPS];
	char c;
	struct lfile *lfp;
	int err;

	verbose_action = 0;

	filep = new_lfile(arname);
	cfp = NULL;

	while (as_getline()) {
		ip = ib;
		c = getnb();
		switch(c) {
		case 'L':
			c = getnb();
			if (c == '0') {
				getid(modname, -1);

				if (!memberp || name_in_list(modname, memberp)) {
					if (create) {
						if (verbose_level)
							fprintf(stdout, "x - %s\n", modname);
						newf = fopen(modname, "w");
						if (!newf) {
							fprintf(stderr, "Error: cannot create '%s'.\n", modname);
							exit(1);
						}
					}
					else {
						if (verbose_level)
							fprintf(stdout, "\n<%s>\n\n", modname);
						newf = stdout;
					}

					while (as_getline()) {
						if (ib[0] == 'L' && ib[1] == '1')
							break;
						fprintf(newf, "%s\n", ib);
					}

					if (create)
						fclose(newf);
				}
			}
			break;
		}
	}

	err = 0;
	for (lfp = memberp; lfp; lfp = lfp->f_flp) {
		if (!lfp->f_found) {
			fprintf(stderr, "Error: object not found '%s'.\n", lfp->f_idp);
			err = 1;
		}
	}
	if (err)
		exit(1);
}



static char *usetxt[] = {
	"Usage: [-]p[mod [count]...] archive [member...]",
	"  where p must be one of:",
	"    d   delete file(s)",
	"    p   print contents of archive",
	"    q   quick append file(s)",
	"    r   insert file(s) with replacement",
	"    x   extract file(s)",
	"  and mod must be one of:",
	"    c   create new lib",
	"    v   request verbose",
   NULL
};



static void usage(void)
{
	char **dp;

	fprintf(stderr, "ASxxxx Library Manager %s\n\n", VERSION);
	for (dp = usetxt; *dp; dp++)
		fprintf(stderr, "%s\n", *dp);

	exit(1);
}



int main(int argc, char *argv[])
{
	char *p, *arname = NULL, c, *name;
	struct lfile *lfp = NULL, *memberp = NULL;
	int i, action = 0;

	if (argc < 3)
		usage();

	p = argv[1];
	if (*p == '-')
		p++;

	while ((c = *p++)) {
		switch (c) {
		case 'd': /* delete */
		case 'p': /* print contents */
		case 'q': /* append */
		case 'r': /* insert and replace */
		case 'x': /* extract */
			if (action && action != c)
				usage();
			action = c;
			break;
		case 'c':
			creation_flag = 1;
			break;
		case 'v':
			verbose_level = 1;
			break;
		default:
			usage();
		}
	}

	if (!action)
		usage();

	for (i=2; i<argc; ++i) {
		p = argv[i];
		name = basenam(p);
		if (strchr(name, ' ')) {
			fprintf(stderr, "Error: filename '%s' contain a space character.\n", name);
			exit(1);
		}
		if (!arname) {
			arname = new(strlen(p)+1);
			strcpy(arname, p);
		}
		else {
			if (!memberp) {
				memberp = new_lfile(name);
				lfp = memberp;
			}
			else {
				lfp->f_flp = new_lfile(name);
				lfp = lfp->f_flp;
			}
		}
	}

	if (!arname)
		usage();

	switch (action) {
	case 'd': replace(arname, memberp, 1); break;
	case 'p': extract(arname, memberp, 0); break;
	case 'q': append(arname, memberp);     break;
	case 'r': replace(arname, memberp, 0); break;
	case 'x': extract(arname, memberp, 1); break;
	}

	return 0;
}
