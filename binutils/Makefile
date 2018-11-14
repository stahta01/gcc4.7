#CFLAGS = -O2 -Wall -Wextra -s
CFLAGS = -O2 -Wall -Wextra -s -ansi -pedantic -D_XOPEN_SOURCE=500

.PHONY: all
all: ranlib

.PHONY: clean
clean:
	rm -f ranlib

.PHONY: distclean
distclean: clean

ranlib: ranlib.c
	$(CC) $(CFLAGS) $(BINUTILS_CFLAGS) -o $@ $< $(BINUTILS_LDFLAGS)
