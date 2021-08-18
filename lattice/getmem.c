/*
 *	g e t m e m
 *
 * Lattice compatible routine to allocate an int number 
 * of bytes from the memory pool.
 *
 *	AMENDMENT HISTORY
 *	~~~~~~~~~~~~~~~~~
 *	11 Mar 95	DJW   - Now uses _LIB_F1_ macro for parameters
 */

#define __LIBRARY__

#include <stdlib.h>

char * getmem _LIB_F1_ (int,  nbytes)
{
	return getml( (long)nbytes );
}
