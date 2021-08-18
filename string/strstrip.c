/*
 *          s t r s t r i p
 *
 *  Routine to remove any occurrences of the given character(s)
 *  from the front of a string, moving string up if necessary.
 *
 *  AMENDMENT HISTORY
 *  ~~~~~~~~~~~~~~~~~
 *  25 OCT 96   DJW   - First version
 */

#include <string.h>

char *strstrip(char *s, int ch)
{
    char * ptr = s;

    while (*ptr == ch)
    {
        ptr++;
    }
    if (ptr != s)
    {
        (void)strcpy (s, ptr);
    }
    return s;
}

