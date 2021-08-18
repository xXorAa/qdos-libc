/*
 *          m b l e n
 *
 *  ANSI defined routine for obtaining the length of
 *  a multi-byte character.
 *
 *  We actually do not really support multi-byte characters
 *  so this will always return 1.
 */

#include <stdlib.h>

int mblen (const char * s, size_t n)
{
    if (s == NULL) {
        return 0;               /* No state encoding */
    } 

    if ( n < sizeof(char)) {
        return -1;
    }

    return (*s ? sizeof(char) : 0);    /* width of a character */
}

