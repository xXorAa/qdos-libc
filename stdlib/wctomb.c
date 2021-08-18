/*
 *          w c t o m b
 *
 *  ANSI defined routine for converting a wide character
 *  to a multi-byte character.
 *
 *  As far as we are concerned all cahracters are the same!
 */

#include <stdlib.h>

int wctomb (char * s, wchar_t pwc)
{
    if (s == NULL) {
        return 0;           /* not state dependant encoding */
    }

    *s = (char)pwc;
    return (sizeof(char));
}

