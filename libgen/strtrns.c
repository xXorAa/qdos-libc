/*
 *      s t r t r n s _ c
 *
 *  Unix compatible routine to copy a string transforming
 *  any characters according to a control string.
 *
 *  Returns a pointer to the result string.
 *
 *  AMENDMENT HISTORY
 *  ~~~~~~~~~~~~~~~~~
 *  29 Aug 94   DJW   - First version
 */

#define __LIBRARY__

#include <libgen.h>

char *  strtrns (const char * str, 
                 const char * old,
                 const char * replacestr,
                 char *       result)
{
    const char *src, *ptr;
    char * dest;

    for (src=str,dest=result ; (*dest = *src) != 0 ; src++, dest++) {
        for (ptr=old ; *ptr ; ptr++) {
            if (*ptr == *dest) {
                *dest = replacestr[ptr - old];
                break;
            }
        }
    }
    return result;
}


