/*
 *			f q s o r t _ c
 *
 *	Lattice compatible routine to sort an array of 
 *	floating point numbers into ascending sequence.
 *
 *	AMENDMENT HISTORY
 *	~~~~~~~~~~~~~~~~~
 *	21 Apr 94	DJW   - Changed parameters to internal compare macro to use
 *						pointer parameters.
 */

#define _LIBRARY_SOURCE

#include <stdlib.h>
#include <qdos.h>

/*
 *	Internal routine to compare two floating point numbers
 */
static
int 	_cmpfloat _LIB_F2_ ( const float *, number1, \
							 const float *, number2)
{
	if (*number1 < *number2) {
		return (-1);
	}
	return (*number1 > *number2);
}


void	fqsort _LIB_F2_(float *,array, int, count)
{
	qsort (array, count, sizeof(float), (int (*)(const void *, const void *))_cmpfloat);
	return;
}
