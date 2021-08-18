/*
 *          s t r f i n d
 *
 * Routine to find the position of string2 in string1,
 *
 * Returns:
 *      -1  if not found
 *      position in string on success
 *
 * AMENDMENT HISTORY
 * ~~~~~~~~~~~~~~~~~
 *  07 Dec 96   DJW   - First version
 */

#define __LIBRARY__

#include <libgen.h>
#include <string.h>

int strfind _LIB_F2_(const char *,  s1, \
                     const char *,  s2)
{
    const char * ptr;

    return ((ptr = strstr(s1,s2)) == NULL)
            ? -1
            : (ptr - s1);
}

