/*
 *      s t p c p y
 *
 * LATTICE compatible routine to copy at most 
 * string src to dst, returning pointer to end.
 *
 * AMENDMENT HISTORY
 * ~~~~~~~~~~~~~~~~~
 *  12 Dec 95   JH    - First version - supplied by Jonathan Hudson
 */

#define __LIBRARY__

#include <string.h>

char * stpcpy _LIB_F2_( char *,         dst,    \
                        const char *,   src)
{
    while ((*dst++ = *src++) != '\0') {
        (void)1;        /* Dummy to suppress compiler warning */
    }
    return (--dst);
}

