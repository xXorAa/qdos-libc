/*
 *      s t r i n s
 *
 *  Lattice compatible routine to insert a string at the
 *  front of another one to create a larger string
 *
 * AMENDMENT HISTORY
 * ~~~~~~~~~~~~~~~~~
 *  21 OCT (`   DJW   - First version.
 */


#define __LIBRARY__

#include <string.h>

void strins _LIB_F2_ ( char *,  to,
                       char *,  from)
{
    int len = strlen(from);

    (void) memmove (&to[len], to, strlen(to)+1);
    (void) memmove (to, from, len);
    return;
}

