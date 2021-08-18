/*
 * strrstr - find last occurrence of wanted in s
 *          found string, or NULL if none
 *
 *  AMENDMENT HISTORY
 *  ~~~~~~~~~~~~~~~~~
 *  12 Mar 98   DJW   - First Version.  Based on ideas from A Ives.
 */

#define __LIBRARY__

#include <string.h>

char *strrstr _LIB_F2_(register const char *, s, \
                       register const char *, wanted)
{
    register const char *scan;
    register char firstc;
    register size_t len;

    /*
     * The odd placement of the two tests is so "" is findable.
     * Also, we inline the first char for speed.
     * The ++ on scan has been moved down for optimization.
     */
    firstc = *wanted;
    len = strlen(wanted);
    for (scan = s + strlen(s) - len ; scan >= s ; scan--)
    {
        if (*scan == firstc)
        {
            if (strncmp (scan, wanted, len) == 0)
            {
                return (char *)scan;
            }
        }
    }
    return(NULL);
}

