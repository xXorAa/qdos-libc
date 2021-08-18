/*
 *			a t o f
 *
 *	Convert ASCII string to double.
 *	Under ANSI superseded by strtod()
 *
 * AMENDMENT HISTORY
 * ~~~~~~~~~~~~~~~~~
 *	02 Jan 95	DJW   - Added missing 'const' qualifier to function declaration
 */

#define __LIBRARY__

#include <stdlib.h>

#ifdef atof
#undef atof
#endif

double atof _LIB_F1_(const char *, s)
{
 return strtod(s, (char **)NULL);
}
