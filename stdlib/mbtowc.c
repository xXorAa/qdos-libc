/*
 *          m b t o w c
 *
 *  ANSI defined routine for converting multi-byte
 *  character to a wide character
 *
 *  AMENDMENT HISTORY
 *  ~~~~~~~~~~~~~~~~~
 *  29 Sep 94   DJW   - Corrected check on 'pwc' being NULL
 */

#include <stdlib.h>

int mbtowc (wchar_t *pwc, const char * s, size_t n)
{
    if (s == NULL) {
        return 0;               /* No state encoding */
    }
    if (pwc != NULL) {
        *pwc = (wchar_t)*s;
    }
    if ( n < sizeof(char)) {
        return -1;
    }
    return (*s ? sizeof(char) : 0);    /* width of a character */
}

