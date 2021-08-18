/*
 *		l a b s
 *
 *	Computes absolute value of x
 */

#define __LIBRARY__

#include <stdlib.h>

long labs _LIB_F1_ (long,  x)
{
	return (( x < 0) ? -x : x);
}

 
