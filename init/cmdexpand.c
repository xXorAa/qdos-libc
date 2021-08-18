/*
 *          c m d e x p a n d
 *
 *  Expand wild cards that occur in the command line.
 *
 *  This routine is called for each argument
 *  It is expected to process them in turn,
 *  and if necessary perform wild card expansion.
 *
 *  The parameter seperator character is also passed
 *  as a parameter.   This is examined to see if the
 *  current parameter was a string (i.e. had ' or "
 *  as the seperator).  If so it is not expanded.
 *
 *  Return code:
 *      -1      Failure occurred.
 *       0      No wild cards in string, so no action taken
 *      +ve     OK.
 *
 * AMENDMENT HISTORY
 * ~~~~~~~~~~~~~~~~~ 
 *  02 Jul 92   EJ    - Fixed bug to make this routine store the file
 *                      name in malloced string space instead of assuming
 *                      local variables remain valid!
 *
 *  12 Sep 92   DJW   - Stopped expansion if first character is '-'.
 *                    - Removed upper limit on length of name list
 *                      (memory permitting).
 *                    - Added checks on running out of memory.
 *
 *  03 Sep 94   DJW   - Revised to take new parameters as part of change
 *                      to program startup sequence to argunpack() routine,
 *                      and to return a success/failure result.
 *                    - Now simply return 0 if no wild card work to do. This
 *                      lets calling code add to the argv vector.
 */

#define __LIBRARY__

#include <qdos.h>
#include <errno.h>
#include <stdlib.h>
#include <string.h>

#define FILEBUF_INIT    1024        /* Initial allocation size for buffer */
#define FILEBUF_INCR    1024        /* Increment size for buffer */

int cmdexpand (char * param, char ***argvptr, int *argcptr)
{
    int     count,sl;
    size_t  bufsize;
    char    *filenamebuf;
    char    *ptr,*safeptr;

    /*
     *  Check to see if we should do wild card expansion.
     *  We only perform wildcard expansion if the parameter
     *  was not a string and if it contains one of the
     *  wild card characters.
     *
     *  We also do not expand any option that starts with '-'
     *  as we then assume that it is a unix stylew option.
     */
    if ((*param == '-')
    ||  (strpbrk(param,"*?") == NULL) ) 
    {
        return 0;
    }

    if ((filenamebuf = malloc (bufsize = FILEBUF_INIT)) == NULL) 
    {
        return -1;
    }
TRYAGAIN:
    count = getfnl(param, filenamebuf, bufsize,QDR_DATA | QDR_PROG);
    if (count == -1  && errno == ENOMEM) 
    {
        /*
         *  We have overflowed the buffer, so we try
         *  to get a bigger buffer and try again.
         */
        bufsize += FILEBUF_INCR;
        if ((filenamebuf = realloc (filenamebuf, bufsize)) == NULL) 
        {
            return -1;
        } else {
            goto TRYAGAIN;
        }
    }
    /*
     *  If no files were found, then return unexpanded.
     */
    if (count == 0) 
    {
        free (filenamebuf);
        return 0;
    }
    /*
     *  Files were found, so add these to the list instead
     *  of the original parameter typed by the user.
     */
    for ( ptr=filenamebuf ; count > 0 ; count -- ) 
    {
        *argvptr = (char **)realloc (*argvptr, (size_t)(((*argcptr) + 2) * sizeof (char *)));
        safeptr=(char *)malloc((size_t)(sl=strlen(ptr)+1));
        if (safeptr == NULL || *argvptr == NULL) 
        {
            return -1;
        }
        (void) memcpy(safeptr,ptr,(size_t)sl);
        (*argvptr)[*argcptr] = safeptr;
        *argcptr += 1;
        ptr += sl;
    }
    free (filenamebuf);
    return *argcptr;
}

