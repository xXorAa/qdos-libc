/*
 *      s t r l w r
 *
 *  Convert a string to lower case.
 *
 *  AMENDMENT HISTORY
 *  ~~~~~~~~~~~~~~~~~
 *  21 Jun 94   DJW   - Casts added to correctly handle characters with
 *                      internal values above 127.
 */

#include <string.h>
#include <ctype.h>

char *strlwr(string)
char *string;
{
    unsigned char *p = (unsigned char *) string;

    while ((*p = (unsigned char)tolower(*p)) != '\0') {
        p++;
    }
    return(string);
}

