/*
 *		d i v
 *
 *	Computes quotient and remainder
 *
 *	The returned quotient 'quot' has the same sign
 *	as n/d, and its magnitude is the largest integer
 *	not greater than abs(n/d).	The remainder 'rem' is
 *	such that quot*d + rem = n.  Behaviour if d == 0
 *	is undefined.
 */

#define __LIBRARY__

#include <stdlib.h>

div_t div _LIB_F2_ (int,  n, \
					int,  d)
{
	div_t	val;

	val.quot = n / d;
	val.rem = n - d * val.quot;
	if (val.quot < 0 && 0 < val.rem) {
		/* Fix a remainder with wrong sign */
		val.quot += 1;
		val.rem -= d;
	}

	return (val);
}
