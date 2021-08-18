/*
 *      s t c c p y
 *
 * LATTICE compatible routine to copy at most n characters of 
 * string src to dst, and always ensure NULL byte at end.
 *
 * AMENDMENT HISTORY
 * ~~~~~~~~~~~~~~~~~
 *  12 Dec 95   DJW   - First version - based on strncpy()
 */

#define __LIBRARY__

#include <string.h>

int stccpy _LIB_F3_(char *,     dst,    \
                    char *,     src,    \
                    int,        n)
{
    long count;

    count = n - 1;
    while (--count >= 0 && (*dst++ = *src++) != '\0')
        continue;
    if (*dst != '\0') {
        *dst = '\0';
        count--;
    }
    return(n - count);
}

