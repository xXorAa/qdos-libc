/*
 *  s t r n i c m p
 *
 *  Case independent comparison of strings
 *
 * AMENDMENT HISTORY
 * ~~~~~~~~~~~~~~~~~
 *  14 Oct 93   DJW   - Removed need for fancy comparison tests on exit path
 *                      by making c1 and c2 into unsigned values.
 *
 *  28 Aug 94   DJW   - Changes to make certain that string treated as
 *                      'unsigned char' as required by ANSI.
 *
 *  26 Jan 95   DJW   - Added 'const' keywords to parameters
 */

#include <sys/types.h>
#include <ctype.h>
#include <string.h>

int strnicmp(str1, str2, len)
  const char *str1;
  const char *str2;
  size_t len;
{
    unsigned char c1, c2;
    long limit = len;

    do {
        if (--limit < 0) {
            return 0;
        }
        c1 = (unsigned char)tolower((unsigned char)*str1);
        c2 = (unsigned char)tolower((unsigned char)*str2);
        str1++; str2++;
    } while(c1 && (c1 == c2));

    return(c1 - c2);
}

