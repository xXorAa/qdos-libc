/*
 *      s t r u p r
 *
 * AMENDMENT HISTORY
 * ~~~~~~~~~~~~~~~~~
 *  28 Aug 94   DJW   - Fixed problem with cast needed for character values
 *                      outside the range 0 to 127.
 */

#include <ctype.h>
#include <string.h>

char *strupr(string)
char *string;
{
    unsigned char *p = (unsigned char *) string;

    while ((*p = (unsigned char)toupper(*p)) != '\0') {
        p++;
    }
    return(string);
}

