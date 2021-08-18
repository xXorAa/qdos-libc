/*
 *          m b s t o w c s
 *
 *  ANSI defined routine for converting a multi-byte character
 *  string to a wide character string.
 *
 *  As far as we are concerned all cahracters are the same!
 */

#include <stdlib.h>
#include <string.h>

size_t mbstowcs (wchar_t * pwc, const char *s, size_t n)
{
    size_t  len;

    (void) strncpy ((char *)pwc, s, n);
    len = strlen(s);
    return (len < n ? len : n);
}

