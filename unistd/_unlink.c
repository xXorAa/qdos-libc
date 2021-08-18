/*
 *          u n l i n k
 *
 *  Unix compatible routine to delete files.
 *
 *  AMENDMENT HISTORY
 *  ~~~~~~~~~~~~~~~~~
 *  10 Jul 93   DJW     Removed assumption that io_delete() sets _oserr.
 *
 *  25 Sep 93   DJW     Amended to check that file exists, and return an
 *                      error code if it does not (as mandated by POSIX).
 *
 *  26 Jan 95   DJW     Added 'const' keyword to function definition
 */

#define __LIBRARY__

#include <errno.h>
#include <qdos.h>
#include <unistd.h>

int unlink _LIB_F1_( const char *, name)
{
    char str[MAXNAMELEN+1];
    chanid_t chid;

    if (! _mkname(str, name))
        return -1;

    if ((chid = io_open(str,OLD_EXCL)) < 0) {
        return (-1);
    } else {
        (void) io_close (chid);
    }

    if ((_oserr = io_delete( str )) < 0) {
        errno = EOSERR;
        return -1;
    }
    return 0;
}

