/*
 *		a r g p a c k
 *
 *	Pack arguments.
 *
 *	This routine takes an array of argument pointers,
 *	and packs this into a single string suitable for
 *	passing as a command line to a program.
 *
 *	It is optional whether an argument should have
 *	additional characters added to protect embedded
 *	spaces and special characters or not.  Whether
 *	this is wanted is specified by the 'flag' parameter.
 *
 *	The memory to hold the resulting command line is
 *	allocated dynamically (using malloc).  The routine
 *	exits with a pointer to the resulting string
 *	or NULL if an error occurs.
 *
 *	AMENDMENT HISTORY
 *	~~~~~~~~~~~~~~~~~
 *	28 Aug 94	DJW   - First version.	 Some of the code is based upon
 *					ideas contributed by Erling Jacobsen.
 *
 *	02 jan 95	DJW   - Added missing 'const' qualifier to function
 *                              declaration
 *
 *      20 Aug 95	DJW   -	Changes to work correctly on EPOC (Psion 3a).
 *
 *      17 Nov 97       DJW   - Changed to set up 'quotes' string dynamically
 *                              at runtime so it can be used from a DYL.
 */

#define __LIBRARY__

#ifdef QDOS
#include <qdos.h>
#include <libgen.h>
#endif /* QDOS */

#ifdef EPOC
#include <cpoclib.h>
#endif /* EPOC */

#include <ctype.h>
#include <stdlib.h>
#include <string.h>

char * argpack (char * const * argv, int flag)
{
	char *	cmdline, *cmdlinenew;
	size_t	cmdlen;
	char *	workbuf = NULL;
	char    quotes[3];

        quotes[0]='\"';
        quotes[1]='\'';
        quotes[2]='\0';

	/*
	 *	Assume initially that we could
	 *	have a zero length command line.
	 */
	if ((cmdline = malloc((size_t)2)) == NULL) {
		return (NULL);
	}
	cmdline[0] = '\0';
	cmdlen = 0;

	/*
	 *	Now try and add any arguments
	 */
	while (*argv != NULL) {
		/*
		 *	Add a space seperator if not first parameter
		 */
		if (cmdlen != 0) 
                {
                        cmdline[cmdlen++] = ' ';
                        cmdline[cmdlen] = '\0';
#if 0
			(void)strcat (cmdline," ");
#endif
		}
		/*
		 *	Allocate temporary buffer to do
		 *	(potential) parameter expansion.
		 *	Play safe with size allocated!
		 */
		free (workbuf);
		if ((workbuf = malloc ((strlen(*argv) * 4) + 3)) == NULL) {
			free (cmdline);
			return NULL;
		}
		/*
		 *	Get (expanded) parameter into workbuf
		 */
		if (flag == 0) {
			(void) strcpy(workbuf,*argv);
		} else {
			int 	whitespace;
			unsigned char * ptr;
			char *dest = workbuf;

			for (ptr = (unsigned char *)*argv, whitespace = 0 ; *ptr ; ptr++) {
				if (isspace(*ptr)) {
					whitespace = 1;
					break;
				}
			}
			if (whitespace) {
				*dest++ = '"';				/* add leading quote if needed */
			}
#if 0
			dest = __Streadd(dest,*argv,NULL,"\"\'");
#else
			dest = __Streadd(dest,*argv,NULL,quotes);
#endif
			if (whitespace) {
				*dest++ = '"';				/* add trailing quote if needed */
			}
			*dest = '\0';					/* add terminator byte */
		}
		/*
		 *	Increase size of buffer used to build
		 *	command line by amount needed to hold
		 *	the next (expanded) parameter to be
		 *	added and then add it to end.
		 */
		cmdlen += strlen(workbuf);
		if ((cmdlinenew = realloc (cmdline,cmdlen+3)) == NULL) {
			free (workbuf);
			free (cmdline);
			return NULL;
		}
		cmdline = strcat (cmdlinenew,workbuf);
		/*
		 *	Try for another one
		 */
		argv++;
	}
	/*
	 *	Free work buffer before returning
	 */
	free(workbuf);
	return (cmdline);
}

