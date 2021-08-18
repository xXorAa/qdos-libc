/*
 *                      s t r b p l
 *
 *  Lattice compatible routine to build a NULL terminated array of pointers
 *  from a list of NULL terminated strings.
 *
 *  Retunrs:
 *      -1      Error - too many strings for array size allowed
 *      +ve     Number of string pointers set up (not counting the
 *              terminating NULL pointer.
 *
 *  Amendment History
 *  ~~~~~~~~~~~~~~~~~
 *  21 Oct 92  DJW  -   First Version
 */

#define __LIBRARY__

#include <string.h>

int strbpl  _LIB_F3_(char **,   s,
                     int,       max,
                     char *,    t)
{
    int  n = 0;

    while ( *t) {
        if (max < n) {
            return -1;
        }
        *s = t;
        s++;
        t += strlen(t) + 1;
    }
    if (max < n) {
        return -1;
    }
    *s = NULL;
    return (n);
}

