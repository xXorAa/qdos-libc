/*
 *	a t o l
 *
 *	Routine to convert ASCII string to long
 *
 *	Synopsis
 *	~~~~~~~~
 *		#include <stdlib.h>
 *		int  atol (const char * nptr);
 *
 *	Description
 *	~~~~~~~~~~~
 *	The 'atol' function converts the initial portion of the string pointed
 *	to by 'nptr' to 'long int' representation.	If the value of the conversion
 *	would not fit in a 'long int' the result is undefined.
 *
 *	Returns
 *	~~~~~~~
 *	The 'atol' function returns the converted value.
 *
 *
 *	AMENDMENT HISTORY
 *	~~~~~~~~~~~~~~~~~
 *	24 Sep 93	DJW   - Changed base to 10 (was 0 = take from string) as
 *						suggested in K&R edition 2.
 *
 *	02 Jan 95	DJW   - Added missing 'const' qualifier to function declaration
 *
 *	11 Mar 95	DJW   - Changed to use new _Strtoul() support routine.
 *					  - Parameter now uses _LIB_F1_ macro.
 */

#define __LIBRARY__

#include <stdlib.h>

#ifdef atol
#undef atol
#endif

long atol  _LIB_F1_(const char *, str)
{
	return ((long) strtoul(str, NULL, 10));
}
