/*
 *	a t o i
 *
 *	Routine to convert ASCII string to integer
 *
 *	Synopsis
 *	~~~~~~~~
 *		#include <stdlib.h>
 *		int  atoi (const char * nptr);
 *
 *	Description
 *	~~~~~~~~~~~
 *	The 'atoi' function converts the initial portion of the string pointed
 *	to by 'nptr' to 'int' representation.  If the value of the conversion
 *	would not fit in a 'int' the result is undefined.
 *
 *	Returns
 *	~~~~~~~
 *	The 'atoi' function returns the converted value.
 *

 *
 *	AMENDMENT HISTORY
 *	~~~~~~~~~~~~~~~~~
 *	24 Sep 93	DJW   - Changed base to 10 (was 0 = take from string) as
 *						suggested in K&R edition 2.
 *
 *	02 Jan 95	DJW   - Added missing 'const' qualifier to function declaration
 *
 *	11 Mar 95	DJW   - Changed to use new _Strtoul() support routine
 *					  - Parameter now uses _LIB_F1_ macro.
 */

#define __LIBRARY__

#include <stdlib.h>

#ifdef atoi
#undef atoi
#endif

int atoi _LIB_F1_(const char *, str)
{
	return ((int) strtoul(str, NULL, 10));
}
