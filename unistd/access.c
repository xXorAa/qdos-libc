/*
 *              a c c e s s
 *
 * Routine to see if a file is accessible (able to be
 * opened).
 *
 * AMENDMENT HISTORY
 * ~~~~~~~~~~~~~~~~~
 *  26 Sep 93   DJW   - Completely re-written as the previous version did
 *                      not really perform the required functionality.
 *
 *  20 Jan 94   DJW   - Corrected sanity check on mode.  Error in this caused
 *                      -1 always to be returned.  Reported by Johnathan Hudson.
 *
 *  21 Jun 94   DJW   - The value for F_OK was changed in the system header
 *                      file to be non-zero so that the sanity checks worked.
 *                      (problem reported by Erling Jacobsen).
 *
 *  08 Aug 95   DJW   - Removed check that at least one of the mode bits is
 *                      set as F_OK is now zero.
 */

#define __LIBRARY__

#include <errno.h>
#include <unistd.h>
#include <sys/stat.h>

int access  _LIB_F2_( char *,   name,
                      int,      mode)
{
    struct stat sbuf;

    /*
     *  First a sanity check on mode
     *      a)  Only the legal bits are specified
     *      b)  At least one of the legal bits is specified.
     */
    if ((mode & ~(F_OK|X_OK|R_OK|W_OK)) != 0) { 
        errno = EINVAL;
        return -1;
    }
    /*
     *  All options for mode require file to exist
     */
    if (_Stat(name, &sbuf) == -1) {
        return -1;
    }
    /*
     *  If X_OK requested, check executable file
     */
    if ((mode & X_OK) != 0  && (sbuf.st_mode & S_IXUSR) == 0) {
        errno = EACCES;
        return -1;
    }
    /*
     *  R_OK and W_OK are implicit if file exists
     */
    return 0;
}

