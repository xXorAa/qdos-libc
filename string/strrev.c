/*
 *      s t r r e v
 *
 *  LATTICE compatible routine to do an "in place" reversal
 *  of a string.
 *
 *  AMENDMENT HISTORY
 *  ~~~~~~~~~~~~~~~~~
 *  25 Aug 93   DJW   - Removed test for empty string as unnecessary
 *                      (reverse an empty string if you want to !!)!
 */

#include <string.h>

char *strrev(string)
char *string;
{
    char *p, *q, c;

    q = p = string;
    while(*q)
        q++;
    while(--q > p) {
        c = *q;         /* get 'back' character */
        *q = *p;        /* put 'front' character in its place */
        *p++ = c;       /* put 'back' into place of 'front' */
    }
    return(string);
}

