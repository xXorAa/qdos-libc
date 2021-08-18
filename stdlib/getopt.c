/*
 *	getopt -- public domain version of standard System V routine
 *
 *	Can strictly enforce the System V Command Syntax Standard;
 *	 provided by D A Gwyn of BRL for generic ANSI C implementations
 *
 *
 *	There are two parts of the command syntax that are normally
 *	relaxed in most implementations:
 *		a) That options that take an argument cannot be clustered
 *		b) That options with a parameter are separated by white space
 *
 *	You can control which behaviour you want by the setting of the
 *	STRICT macro below:
 *
 *	non-zero	Strictly enforces the System V Command Syntax Standard;
 *				provided by D A Gwyn of BRL for generic ANSI C implementations
 *
 *	0			Allow the relaxed format
 */

#define __LIBRARY__

#define STRICT 0

#include <stdlib.h>
#include <stddef.h>
#include <stdio.h>
#include <string.h>


#ifdef __STDC__
#define _P_(params) params
#else
#define _P_(params) ()
#endif

static int Err	   _P_((char *, char *, int));

#undef _P_


int opterr = 1; /* error => print message */
int optind = 1; /* next argv[] index */
char *optarg = NULL;	/* option parameter if any */


int getopt _LIB_F3_(int,	  argc, 		/* argument count from main */ \
					char **,  argv, 		/* argument vector from main */ \
					char *,   optstring)	/* allowed args, e.g. "ab:c" */
{
	static int sp = 1;	/* position within argument */
	int osp;			/* saved 'sp' for param test */
	int c;				/* option letter */
	char *cp;			/* -> option in 'optstring' */

	optarg = NULL;

	if ( sp == 1 ) {         /* fresh argument */
		if ( optind >= argc 	/* no more arguments */
		|| argv[optind][0] != '-'	/* no more options */
		|| argv[optind][1] == '\0' ) /* not option; stdin */
			return EOF;
		else if ( strcmp( argv[optind], "--" ) == 0 ) {
			++optind;	/* skip over "--" */
			return EOF; /* "--" marks end of options */
		}
	}

	c = argv[optind][sp];	/* option letter */
	osp = sp++; 			/* get ready for next letter */

	if ( argv[optind][sp] == '\0' ) {
		/* end of argument */
		++optind;		/* get ready for next try */
		sp = 1; 		/* beginning of next argument */
	}

	if ( c == ':'			/* optstring syntax conflict */
	  || (cp = strchr( optstring, c )) == NULL	/* not found */
	   )
		return Err( argv[0], "illegal option", c );

	if ( cp[1] == ':' ) {
		/* option takes parameter */
		if ( optind >= argc )
			return Err( argv[0],"option requires an argument",c);

#if (STRICT != 0)
		if ( osp != 1 )
			return Err( argv[0],"option must not be clustered",c);

		if ( sp != 1 )		/* reset by end of argument */
			return Err( argv[0],"option must be followed by white space",c);
		optarg = (char *)argv[optind];	/* make parameter available */
#else
		optarg = (char *)argv[optind] + (sp-(sp==1));  /* make parameter available */
#endif /* STRICT */
		sp = 1;
		++optind;						/* skip over parameter */
	}

	return c;
}

/*
 *	Local function that optionally prints a message, and returns '?'
 */
static int Err _LIB_F3_(char *, name,	  /* program name argv[0] */	\
						char *, mess,	  /* specific message */		\
						int,	c)		  /* defective option letter */
{
	if ( opterr )
		(void) fprintf( stderr, "%s: %s -- %c\n", name, mess, c );

	return '?'; 		/* erroneous-option marker */
}
