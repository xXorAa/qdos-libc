/*
 *              d u p 2
 *
 * Routine to duplicate at level 1 the number of file
 * descriptors accessing the same file, given the second
 * descriptor to use explicitly.  If necessary, an extra
 * UFB will be created
 *
 * CAUTION.
 * If necessary, new descriptors will be created which
 * might move the UFB table in memory.
 */

#define __LIBRARY__

#include <unistd.h>
#include <fcntl.h>
#include <errno.h>

int dup2( fd, nfd )
    int fd; /* File descriptor to duplicate */
    int nfd; /* File descriptor to re-allocate */
{
    struct UFB *ufb, *nufb;

    /* Check the new file handle exists */
    if ( !(nufb=_Newufb(nfd))) {
        /* Error code already set */
        return -1;
    }
    /* Check the original file handle */
    if( !( ufb = _Chkufb( fd ))) {
        errno = EINVAL;
        return -1;
    }

    if( nufb->ufbflg & UFB_OP)
        /* File is open - close it */
        (void) close( nfd );

    /* Set the UFB_DP flag to say file has been duplicated */
    ufb->ufbflg |= UFB_DP;
    *nufb = *ufb; /* Structure copy */
    return nfd;
}

