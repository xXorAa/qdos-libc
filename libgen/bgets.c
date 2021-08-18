/*
 *          b g e t s
 *
 *  Routine to read a file up to next delimiter
 *
 *  bgets reads characters from stream until either maxcount is
 *  exhausted or one of the characters in breakstring is
 *  encountered in the stream.   The read data is terminated
 *  with a null byte and apointer to the trailing null is
 *  returned.  If a breakstring character is encountered the
 *  last non-null is the delimiter character that terminated
 *  the scan.
 *
 *  There is always room reserved in the buffer for the trailing null.
 *
 *  If breakstring is a null pointer, the value of the breakstring
 *  from the previous call is used.   If breakstring is null at the
 *  first call, no characters will be used to delimit the string.
 *
 *  NULL is returned on error or end-of-file.   Reporting the
 *  condition is delayed to the next call if any characters were
 *  read but not yet returned.
 *
 * AMENDMENT HISTORY
 * ~~~~~~~~~~~~~~~~~
 *  14 Dec 96   DJW   - First version
 */

#include <libgen.h>
#include <stdlib.h>
#include <string.h>

static  char *  breakstr = NULL;

char *  bgets (char *  buffer,
               size_t  maxcount,
               FILE *  stream,
               const char * breakstring)
{
    char *  bufptr;
    int     readchar;
    size_t  readcount;

    /*
     *  Set initial value
     */
    if (breakstr == NULL)
    {
        breakstr = strdup("");
    }
    /*
     *  See if string to be changed
     */
    if (breakstring != NULL
    &&  strcmp(breakstring,breakstr) != 0)
    {
        free (breakstr);
        breakstr = strdup ((char *)breakstring);
    }

    for (readcount=0, bufptr = buffer ; readcount < maxcount ; bufptr++, readcount++)
    {
        if ((readchar = getc (stream)) < 0)
        {
            if (readcount != 0)
            {
                break;
            }
            else
            {
                return NULL;
            }
        }
        if (strchr(breakstr,readchar) != NULL)
        {
            break;
        }
    }
    *bufptr = '\0';
    return bufptr;
}
