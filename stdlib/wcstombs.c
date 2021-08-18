/*
 *          w c s t o m b s
 *
 *  ANSI defined routine for converting a wide character
 *  string to a multi-byte character string.
 *
 *  As far as we are concerned all cahracters are the same!
 *
 *  AMENDMENT HISTORY
 *  ~~~~~~~~~~~~~~~~~
 *  29 Aug 93   DJW   - First Version
 */

#include <stdlib.h>
#include <string.h>

size_t wcstombs (char * s, const wchar_t * pwc, size_t n)
{
    size_t  len;

    (void) strncpy (s, (const char *)pwc, n);
    len = strlen((const char *)pwc);
    return (len < n ? len : n);
}

