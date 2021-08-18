/*
 *          b a s e n a m e
 *
 *  Routine to return the last element of a path name
 *  Any trailing directory separator characters are first
 *  deleted (changed to NULL characters).
 *
 *  This can be quite a problem on a QDOS system as the
 *  extension seperator is the same as the directory
 *  seperator.  Therefore this algorithm is rather
 *  heuristic in nature:
 *
 *  a)  If we ever have more than one consecutive underscore,
 *      then we assume that all except the first are really part
 *      of the filename (we also allow for the first being any of
 *      the other supported directory separators).
 *
 *  b)  If we have a version 2+ filing system, then we look for
 *      hard directories, and report the name relative to that.
 *
 *  c)  If we have version 1 filing system then we assume that
 *      the extension can be up to 4 characters - if there are
 *      more at the end of the filname then we assume that the
 *      filename has no extension.  We then look backwards for
 *      a directory seperator character.
 *
 * Returns:
 *  Pointer to basename.
 *
 * AMENDMENT HISTORY
 * ~~~~~~~~~~~~~~~~~
 *  07 Dec 96   DJW   - First version
 */

#include <libgen.h>
#include <string.h>
#ifdef QDOS
#include <qdos.h>
#endif /* QDOS */

char *  basename (char *  pathname)
{
    char * ptr;
    char * ptrend;

#ifdef QDOS
    /*
     *  If name begins with a devicename, then
     *  make sure we do not treat it as a filename.
     */
    if (isdirdev(pathname) != 0)
    {
        if ((ptr = strchr(pathname,'_')) == NULL)
        {
            ptr = pathname + strlen(pathname);
        }
        else
        {
            ptr++;
        }
        pathname = ptr;
    }
#endif /* QDOS */
    /*
     *  Trim off any trailing directory
     *  separator characters.
     */
    *(strrspn (pathname,"_/\\")) = '\0';


    ptrend = pathname + strlen(pathname);

    /*
     *  Look for first separator
     */
    for (ptr=ptrend ; --ptr > pathname ; )
    {
        if (strchr("._/\\",*ptr) != NULL
        &&  strchr("_/\\",ptr[-1]) == NULL)
        {
            break;
        }
    }
    /*
     *  If this looks like an extension,
     *  then look for next one.
     */
    if (ptr > pathname
    &&  (ptrend - ptr) <= 4)
    {
        for (ptr-- ; ptr > pathname ; ptr--)
        {
            if (strchr("_/\\",*ptr) != NULL
            &&  strchr("_/\\",ptr[-1]) == NULL)
            {
                break;
            }
        }
    }
    if (ptr != pathname)
    {
        ptr++;
    }
    return ptr;
}

