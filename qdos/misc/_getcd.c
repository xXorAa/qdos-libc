/*
 *				_ g e t c d  / _ s e t c d 
 *
 * Internal library routine to get and set the current directory
 * path.   These are actually the only routines that know the
 * actal mechanics of how these name are stored.
 *
 * Fot the _getcd() routine, if no path exists, then a zero length string 
 * is returned.  If passed a NULL for the buffer, tries to malloc a buffer.
 *
 * AMENDMENT HISTORY
 * ~~~~~~~~~~~~~~~~~
 *	21 Nov 93	DJW   - Added in _set_dir() routine and renamed in to _setcd().
 *						This is to isolate in a single module the routines
 *						that are aware of the mechanics of how the names are
 *						stored.
 *					  - Now ignore the 'size' parameters if the 'str'
 *						parameter is NULL.
 *
 *	11 mar 95	DJW   - Now uses _LIB_F3_ macro for parameters
 */

#define __LIBRARY__

#include <qdos.h>
#include <stdlib.h>
#include <string.h>
#include <errno.h>

char *_getcd  _LIB_F3_ (char *, dtg, \
						char *, str, \
						int,	size)
{
	char	*dirstr;
	size_t	dlen;

	if ((dirstr = getenv(dtg))==(char *)NULL) {
		dirstr = "";
	}

	dlen = strlen( dirstr ) + 1; /* Length of directory to get */

	if (str == (char *)NULL) {
		/*
		 *	We must allocate space
		 */
		if(!( str = (char *)malloc( (size_t)size ))) {
			return (char *)NULL;
		}
	} else {
		/* 
		 *	Check if there is enough space to get the directory
		 */
		if( size < dlen ) {
			errno = ENOSPC; /* No space */
			return (char *)NULL;
		}
	}
	(void) strcpy( str, dirstr);
	return str;
}

/*
 *	Internal routine to store a directory routine. 
 */
void _setcd _LIB_F2_(char *,  tag, \
					 char *, value)
{
	char	envstring[50];

	(void) strcpy (envstring,tag);
	(void) strcat (envstring,"=");
	(void) strcat (envstring,value);
	(void) putenv (envstring);
	return;
}
