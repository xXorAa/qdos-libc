/*
 *      s e e k d i r
 *
 * Seek to a particular directory entry (UNIX style)
 *
 * AMENDMENT HISTORY
 * ~~~~~~~~~~~~~~~~~
 *  12 Aug 93   DJW   - Added some error checjing
 *                      (based on ideas from Richard Kettlewell )
 */

#include <dirent.h>
#include <errno.h>
#include <stddef.h>

void seekdir   (dirp, loc)
  DIR * dirp;
  long  loc;
{
    if ( dirp == NULL) {
        errno = EBADF;                          /* SVR4 error code */
        return;
    }
    if (loc < 0 || (loc & 63) ) {
        errno = EINVAL;
        return;
    }
    /*
     *  NB. We do not check that the address specified really fits
     *      within the QDOS directory.  This is consistent with the
     *      Unix treatment which permits you to set positions that
     *      are beyond the real end!
     */
    dirp->dd_loc = loc;
    return;
}

