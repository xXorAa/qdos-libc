/*
 *			d q s o r t _ c
 *
 *	Lattice compatible routine to sort an array of double
 *	precision floating point numbers into ascending sequence.
 *
 *	AMENDMENT HISTORY
 *	~~~~~~~~~~~~~~~~~
 *	21 Apr 94	DJW   - Changed parameters to internal compare macro to use
 *						pointer parameters.
 *
 *	11 Mar 95	DJW   - Now uses _LIB_F2_ macro for parameters.
 */

#define __LIBRARY__

#include <sys/types.h>
#include <stdlib.h>

/*
 *	Internal routine to compare double precision floating point numbers
 */
static
int 	_cmpdouble _LIB_F2_(const double *, number1, \
							const double *, number2)
{
	if (*number1 < *number2) {
		return (-1);
	}
	return (*number1 > *number2);
}


void	dqsort _LIB_F2_ (double *,	 array, \
				int,		count)
{
	qsort (array, count, sizeof(double), (int (*)(const void *,const void *))_cmpdouble);
	return;
}
