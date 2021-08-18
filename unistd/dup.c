/*
 *                  d u p
 *
 * Routine to duplicate at level 1 the number of file
 * descriptors accessing the same file.
 *
 * CAUTION.
 * If necessary, new descriptors will be created which
 * might move the UFB table in memory.
 */

#define __LIBRARY__

#include <unistd.h>
#include <fcntl.h>
#include <errno.h>

int dup _LIB_F1_(int,    fd)            /* File descriptor to duplicate */
{
    int nfd;
    struct UFB *ufb, *nufb;

    if( !( ufb = _Chkufb( fd ))) {
        return -1;
    }

    /* Look for a new file handle to use */
    for( nfd = 0; nfd < _nufbs; nfd++) {
        if(!( (nufb = &_ufbs[nfd]) -> ufbflg & UFB_OP)) {
            break;
        }
    }
    if( nfd == _nufbs) {
        /* Try to extend the UFB table */
        if ((nufb = _Newufb(nfd)) != NULL) {
            ufb = _Chkufb(fd);   /* reset this pointer which may have changed */
        } else {
            /* Not enough file handles available */
            errno = EMFILE;
            return -1;
        }
    }

    /* Set the UFB_DP flag to say file has been duplicated */
    ufb->ufbflg |= UFB_DP;
    *nufb = *ufb; /* Structure copy */
    return nfd;
}

