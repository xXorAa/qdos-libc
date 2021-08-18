/*
 *          f q s t a t
 *
 *  Get the file information from QDOS, given a 
 *  level 1 file descriptor.
 *  (QDOS specific instance of fstat)
 *
 *  Returns:
 *          0   Success
 *          -1  Failure.  Details given by errno and _oserr variables
 *
 *  AMENDMENT HISTORY
 *  ~~~~~~~~~~~~~~~~~
 *  14 Oct 93   DJW     New version.  Most of previous code moved to the
 *                      support routine _fqstat().
 */

#define __LIBRARY__

#include <fcntl.h>
#include <qdos.h>

int  fqstat _LIB_F2_ (int,              fd,
                      struct qdirect *, stat)
{
    struct UFB *uptr;

    if ( (uptr = _Chkufb( fd )) == NULL) {
        return -1;
    }
    return _fqstat(uptr->ufbfh, stat);
}

