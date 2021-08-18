/*
 *  t e l l d i r
 *
 *  BSD compatible routine to tell us where we are 
 *  in a directory (also supported by UNIX SVR4).
 *
 *  AMENDMENT HISTORY
 *  ~~~~~~~~~~~~~~~~~
 *  21 Aug 93   DJW   - Error checking added.
 *                      (based on ideas from Richard Kettlewell)
 */

#include <dirent.h>
#include <errno.h>
#include <stddef.h>

long telldir (dirp)
  DIR * dirp;
{
    if (dirp == NULL) {
        errno = EBADF;
        return -1;
    }
    return dirp->dd_loc;
}

