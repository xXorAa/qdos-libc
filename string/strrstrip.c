/*
 *          s t r r s t r i p
 *
 *  Routine to remove any occurrences of the given character
 *  from the end of a string.
 *
 *  AMENDMENT HISTORY
 *  ~~~~~~~~~~~~~~~~~
 *  25 OCT 96   DJW   - First version
 */

#include <string.h>

char *strrstrip(char *s, int ch)
{
    size_t  len = strlen(s);

    while (len > 0 && s[len-1] == ch)
    {
        len--;
    }
    s[len] = '\0';
    return s;
}

