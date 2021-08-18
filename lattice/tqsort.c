/*
 *			t q s o r t _ c
 *
 *	Lattice compatible routine to sort an array of 
 *	string pointers into ascending string sequence.
 *
 *	AMENDMENT HISTORY
 *	~~~~~~~~~~~~~~~~~
 *	21 Apr 94	DJW   - Changed parameters to internal compare macro to use
 *						pointer parameters.
 *
 *	11 mar 95	DJW   - Now uses _LIB_F2_ macro for parameters
 *
 *	05 Apr 95	DJW   - Corrected so that functions correctly.	Was previously
 *						acting as though an array of strings (rather than
 *						pointers to strings) had been passed.
 *						Problem reported by Dave Woodman.
 */

#define __LIBRARY__

#include <sys/types.h>
#include <stdlib.h>
#include <string.h>

/*
 *	Internal routine to compare two short integer numbers
 */
static
int 	_cmpstrings _LIB_F2_ (const char **,  string1, \
							const char **,	string2)
{
	return (strcmp(*string1, *string2));
}


void	tqsort _LIB_F2_(char **, array, \
						int,	 count)
{
	qsort (array, count, sizeof(char *), (int (*)(const void *, const void *))_cmpstrings);
	return;
}
