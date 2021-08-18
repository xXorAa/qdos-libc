/*
 *      f t r u n c a t e
 *
 * Unix comatible routine to truncate a file at a given
 * position given a level 1 file descriptor.
 *
 *  AMENDMENT HIISTORY:
 *  ~~~~~~~~~~~~~~~~~~
 *  21 Jun 93   DJW   - Removewd assumption that fs_pos() set _oserr on error,
 *                      instead works on return value.
 */

#define __LIBRARY__

#include <unistd.h>
#include <qdos.h>
#include <fcntl.h>
#include <errno.h>

int ftruncate _LIB_F2_( int,     fd,        /* File descriptor */   \
                        off_t,   length)    /* Length to truncate at */
{
    struct UFB *uptr;

    if(!( uptr = _Chkufb( fd )))
        return -1;

    /*
     *  Try and seek to the correct position.
     *  N.B.  This must not be greater than current length!
     */
    if( (_oserr = fs_pos( uptr->ufbfh, length, (short)0)) != length) {
        errno = EOSERR;
        return -1;
    }

    /*
     *  Now do the truncate
     */
    if( (_oserr=io_trunc( uptr->ufbfh, (timeout_t)-1)) != 0) {
        errno = EOSERR;
        return -1;
    }

    return 0;
}

