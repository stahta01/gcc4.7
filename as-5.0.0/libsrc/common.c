/* common.c */



static void *new(unsigned int n)
{
	char *p;

	p = (char *)calloc(n, sizeof(char));
	if (!p) {
		fprintf(stderr, "Error: out of space!\n");
		exit(1);
	}

	return p;
}



static struct lfile *new_lfile(char *filename)
{
	struct lfile *lfilep;

	lfilep = (struct lfile *)new(sizeof(struct lfile));
	lfilep->f_idp = (char *)new(strlen(filename)+1);
	strcpy(lfilep->f_idp, filename);

	return lfilep;
}



static int get(void)
{
	int c;

	if ((c = *ip) != 0)
		++ip;

	return c;
}



static int getnb(void)
{
	int c;

	while (((c=get())==' ') || (c=='\t'));

	return c;
}



static void getid(char *id, int c)
{
	char *p;

	if (c < 0)
		c = getnb();

	p = id;

	do {
		if (p < &id[NCPS-1])
			*p++ = c;
	} while ((ctype[c=get()] & (LETTER|DIGIT)) || (c == '-'));

	if (c != 0)
		--ip;

	*p = 0;
}



static int as_getline(void)
{
	static FILE *sfp = NULL;
	int ret, i;

	ret = 1;

loop:
	if (sfp == NULL || fgets(ib, sizeof(ib), sfp) == NULL) {
		/* close just finished file */
		if (sfp != NULL) {
			fclose(sfp);
			sfp = NULL;
		}

		/* advance current file */
		if (cfp == NULL)
			cfp = filep;
		else
			cfp = cfp->f_flp;

		/* open new file */
		if (cfp != NULL) {
#ifdef VERBOSE_LEVEL
			if (verbose_level && verbose_action)
				fprintf(stdout, "%c - %s\n", verbose_action, cfp->f_idp);
#endif
			sfp = fopen(cfp->f_idp, "r");
			if (!sfp) {
				fprintf(stderr, "Error: cannot open '%s'.\n", cfp->f_idp);
				exit(1);
			}
			ret = 2;
			goto loop;
		}
		else {
			return 0;
		}
	}

	/* strip end of line */
	i = strlen(ib);
	if (i > 0) {
		if (ib[i-1] == '\n')
			ib[--i] = 0;
		if (i > 0) {
			if (ib[--i] == '\r')
				ib[i] = 0;
		}
	}

	return ret;
}
