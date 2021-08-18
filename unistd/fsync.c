/*
 *              f s y n c
 *
 *  Unix compatible routine to flush a level 1 file.
 *  Just calls QDOS flush call with infinite -1 timeout.
 *
 *  AMENDMENT HISTORY
 *  ~~~~~~~~~~~~~~~~~
 *  11 Jul 93   DJW     Removed assumption that fs_check() sets _oserr.
 */

#define __LIBRARY__

#include <unistd.h>
#include <qdos.h>
#include <fcntl.h>
#include <errno.h>

int fsync( fd )
int fd; /* file handle to sync */
{
    struct UFB *uptr;

    if( !( uptr = _Chkufb( fd ))) {
        return -1;
    }

    if( (_oserr = fs_flush( uptr->ufbtyp == D_SOCKET ? 
                uptr->ufbfh1 : uptr->ufbfh, (timeout_t)-1)) != 0 ) {
        errno = EOSERR;
        return -1;
    }
    return 0;
}

