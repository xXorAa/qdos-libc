/*
 *				c t i m e
 *
 *	ANSI routine to convert <rawtime> to a string.
 *
 *	A 26 character fixed field stringis created from the raw time value.
 *	The following is an example of what this string might look like:
 *
 *		"Wed Jul 08 18:43:07 1987\n\0"
 *
 *	A 24-hour clock is used. A pointer to the formatted string, which is
 *	held in an internal buffer (shared with asctime(), is returned.
 *
 *	AMENDMENT HISTORY
 *	~~~~~~~~~~~~~~~~~
 *	02 Jan 95	DJW   - Added missing 'const' qualifer to function declaration
 */

#define __LIBRARY__

#include <time.h>

char * ctime _LIB_F1_(const time_t *,   rawtime)
{
	return (asctime(localtime(rawtime)));
}
