/*
 *	bsearch(3)
 *
 *	Author: Terrence Holm		   Aug. 1988
 *
 *
 *	Performs a binary search for a given <key> within a sorted
 *	table. The table contains <count> entries of size <width>
 *	and starts at <base>.
 *
 *	Entries are compared using keycmp( key, entry ), each argument
 *	is a (void *), the function returns an int < 0, = 0 or > 0
 *	according to the order of the two arguments.
 *
 *	Bsearch(3) returns a pointer to the matching entry, if found,
 *	otherwise NULL is returned.
 *
 *	AMENDMENT HISTORY
 *	~~~~~~~~~~~~~~~~~
 *	02 Jan 95	DJW   - Added missing 'const' qualifiers to function declaration
 */

#define __LIBRARY__

#include <stdlib.h>

#ifdef __STDC__
#define _P_(params) params
#else
#define _P_(params) ()
#endif

void *bsearch  _LIB_F5_(const void *,	key, \
						const void *,	basefix, \
						size_t, 		count, \
						size_t, 		width, \
						int,		(*keycmp) _P_((const void *, const void *)))
{
	void *mid_point;
	int cmp;
	const void *base = basefix;

	while (count != 0) {
		mid_point = (void *)((char *)base + width * (count >> 1));

		cmp = keycmp(key, mid_point);

		if (cmp == 0) return(mid_point);

		if (cmp < 0)
			count >>= 1;
		else {
			base = (void *)((char *)mid_point + width);
			count = (count - 1) >> 1;
		}
	}

	return(NULL);
}

#undef _P_
