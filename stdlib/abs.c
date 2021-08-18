/*
 *		a b s
 *
 *	Computes absolute value of x
 *
 * AMENDMENT HISTORY
 * ~~~~~~~~~~~~~~~~~
 *	25 Feb 95	DJW   - Amended to use _LIB_F1_ macro for parameters
 */

#define _LIBRARY_SOURCE

#include <stdlib.h>

int abs _LIB_F1_(int, x)
{
	return (( x < 0) ? -x : x);
}

 
