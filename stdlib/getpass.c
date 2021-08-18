/*
 *      g e t p a s s
 *
 *  Unix/Posix compatible routine to read a string of characters
 *  without echo.  Reads up to the next newline or EOF.
 *
 *  To get the closes simulation to Unix that we can, we read/write
 *  from the stderr channel.
 *
 *  AMENDMENT HISTORY
 *  ~~~~~~~~~~~~~~~~~
 *  10 Mar 96   DJW   - First version
 */

#define __LIBRARY__

#include <stdlib.h>
#include <string.h>
#include <limits.h>
#include <errno.h>
#include <qdos.h>

char *  getpass _LIB_F1_ (char *,  prompt)
{
    static  char buffer[PASS_MAX+1];
    char    c;
    int     count;
    chanid_t chid;

    /*
     *  Check that stderr is a console channel
     */
    chid = getchid(2);
    if (! iscon(chid, 1)) {
        return NULL;
    }
    /*
     *  Output the prompt
     */
    (void)io_sstrg(chid, (timeout_t)-1, prompt, (short)strlen(prompt));
    /*
     *  Read until we get EOF or a newline
     *  (or any other error)
     *  Only PASS_MAX characters are significant
     */
    for (count = 0 ; ; ) {
        switch (io_fbyte(chid, (timeout_t)-1, &c)) {
            case 0:
                    if (c == '\n') {
                        break;
                    }
                    if (count < PASS_MAX) {
                        buffer[count++] = c;
                    }
                    continue;
            case ERR_EF:
                    break;
            default:
                    return NULL;
        }
    }
    buffer[count] = '\0';
    return  buffer;
}
 
