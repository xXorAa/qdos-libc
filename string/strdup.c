/*
 *          s t r d u p
 *
 *  Unix compatible routine to create a duplicate of a string in 
 *  local string space using malloced memory.
 *
 *  AMENDMENT HSITORY
 *  ~~~~~~~~~~~~~~~~~
 */

#include <stdlib.h>
#include <string.h>

char *strdup(s)
char *s;
{
    char *dup;

    dup = (char *)malloc(strlen(s)+1);
    if (dup != NULL){
        (void) strcpy(dup, s);
    }
    return dup;
}

