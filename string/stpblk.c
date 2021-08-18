/*
 *  s t p b l k
 *
 *  LATTICE compatible routine to skip blanks (white space)
 */

#define __LIBRARY__

#include <string.h>
#include <ctype.h>

char * stpblk _LIB_F1_(char *, s)
{
    while (*s && isspace(*s)) {
        s++;
    }
    return s;
}

