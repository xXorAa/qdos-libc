/*
 *          d i r n a m e
 *
 *  Routine to return the parent directory element of a path name
 *  Any trailing directory separator characters are first
 *  deleted (changed to NULL characters).
 *
 *  This can be quite a problem on a QDOS system as the
 *  extension seperator is the same as the directory
 *  seperator.  Therefore this algorithm is rather
 *  heuristic in nature.  To ensure consitency, we
 *  actually use the basename() function to determine
 *  which is the filename part, and then remove this
 *  from the given path.
 *
 *
 * Returns:
 *  Pointer to directory name.
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

char *  dirname (char *  pathname)
{
    char * ptr;

    if (pathname == NULL || *pathname=='\0')
    {
        return ("");
    }
    ptr = basename(pathname);
    if (ptr == pathname)
    {
        return ("");
    }
    ptr--;
#ifdef QDOS
    if (isdirdev(pathname) != 0
    && strchr(pathname,'_') == ptr) {
        ptr++;
    }
#endif /* QDOS */
    *ptr = '\0';
    return (pathname);
}

