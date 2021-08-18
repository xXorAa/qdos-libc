/*
 *      s t r i c m p
 *
 *  compare string s1 to s2 - ignore case
 *
 *  returns:
 *      -ve     less than
 *      0       equal
 *      +ve     greater than
 *
 *  AMENDMENT HISTORY
 *  ~~~~~~~~~~~~~~~~~
 *  21 Jun 94   DJW   - Casts added to correctly handle characters with
 *                      internal values above 127.
 *
 *  28 Aug 94   DJW   - Changes to make certain that string treated as
 *                      'unsigned char' as required by ANSI.
 *
 *  26 Jan 95   DJW   - Added 'const' keywords to parameter definitions
 */

#include <string.h>
#include <ctype.h>

int stricmp(scan1, scan2)
const char *scan1;
const char *scan2;
{
    unsigned char c1, c2;

    do {
        c1 = (unsigned char)tolower((unsigned char)*scan1);
        c2 = (unsigned char)tolower((unsigned char)*scan2);
        scan1++; scan2++;
    } while (c1 && (c1 == c2));

    return(c1 - c2);
}

