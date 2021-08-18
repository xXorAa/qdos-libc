/*
 *		_ c a l l o c
 *
 * Routine to do a calloc call for allocating memory.
 *
 * AMENDMENT HISTORY
 * ~~~~~~~~~~~~~~~~~
 *	25 Feb 95	DJW   - Amended to use _LIB_F2_ macro for parameters
 */

#define _LIBRARY_SOURCE

#include <stdlib.h>
#include <string.h>

void *calloc _LIB_F2_(size_t,	nelt, \
					  size_t,	eltsize)
{
	long i = nelt * eltsize;
	char *ret;

	if ((i <= 0L)
	|| ((long)(ret = (char *)malloc((size_t)(i)))<= 0L) ) {
		return NULL;
	}

	/*
	 *	Now set the area to zeros
	 */
	return memset( (void *)(ret), 0, (size_t)(i));
}
