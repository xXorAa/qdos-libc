/*
 *			s q s o r t _ c
 *
 *	Lattice compatible routine to sort an array of 
 *	short integer numbers into ascending sequence.
 *
 *	AMENDMENT HISTORY
 *	~~~~~~~~~~~~~~~~~
 *	21 Apr 94	DJW   - Changed parameters to internal compare macro to use
 *						pointer parameters.
 *
 *	11 Mar 95	DJW   - Now uses _LIB_F2_ macro for parameters
 */

#define __LIBRARY__

#include <stdlib.h>
#include <qdos.h>

/*
 *	Internal routine to compare two short integer numbers
 */
static
int 	_cmpshort _LIB_F2_ (const short *,	number1, \
							const short *,	number2)
{
	if (*number1 < *number2) {
		return (-1);
	}
	return (*number1 > *number2);
}

void	sqsort _LIB_F2_ (short *, array, \
						 int,	  count)
{
	qsort (array, count, sizeof(short), (int (*)(const void *, const void *))_cmpshort);
	return;
}
