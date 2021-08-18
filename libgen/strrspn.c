/*
 *      s t r r s p n
 *
 *  Unix compatible routine to find the beginning of
 *  the characters to be trimmed from a string.
 *
 *  Returns a pointer to the first character from string
 *  such that this and all remaining characters are in
 *  the list of trim characters.
 *
 *  AMENDMENT HISTORY
 *  ~~~~~~~~~~~~~~~~~
 *  07 Dec 96   DJW   - First version
 */

#include <libgen.h>
#include <string.h>

char *  strrspn (const char * string, 
                 const char * trimchar)
{
    const char *ptr;

    for (ptr = string + strlen(string) ; --ptr >= string ; ) 
    {
        if (strchr(trimchar, *ptr) == NULL)
        {
            break;
        }
    }
    ptr++;
    return (char *)ptr;
}

