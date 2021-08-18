/*
 *		i t o a
 *
 *		Extracted from Kernighan & Richie Edition 1
 *
 *		NOTE.	Not part of ANSI, POSIX or Unix SVR4 libraries.
 *				Really only included for LATTICE compatibility.
 *
 *	AMENDMENT HISTORY:
 *	~~~~~~~~~~~~~~~~~
 *	25 Aug 92	DJW   - Reversed order of parameters to come inline
 *						with accepted useage.
 *						(pointed out by Peter Tillier)
 */

#define __LIBRARY__

#include <qdos.h>
#include <string.h>

/*
 *	Convert an integer value into a ASCII decimal string.
 *	Return the address of the target string
 */
char *	itoa _LIB_F2_ (int, 	value, \
					   char *,	dest)
{
	int  i, sign;

	if ((sign = value) < 0) 	/* record sign */
		value = -value;
	i = 0;
	do {                        /* generate digits in reverse sequence */
		dest[i++] = (char)(value % 10 + '0');
	} while (( value /= 10) > 0);
	if (sign < 0)
		dest[i++] = '-';
	dest[i] = '\0';
	return (strrev(dest));
}
