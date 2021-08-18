/*
 *                  u s e c h i d
 *
 *  This routine is used to set up a level 1 file descriptor
 *  for a file that has been opened at Level 0 (i.e. QDOS)
 *
 */

#define __LIBRARY__

#include <qdos.h>
#include <fcntl.h>

int usechid _LIB_F1_ (chanid_t,   chanid)
{
    int fd;
    struct UFB *uptr;

    if ((fd = _Openufb()) < 0) {
        return (-1);
    }
    uptr = &_ufbs[fd];
    uptr->ufbflg = UFB_OP | UFB_WA | UFB_RA | UFB_ND;   /* open read/write */
    uptr->ufbtyp = D_CON;
    uptr->ufbfh  = chanid;
    return fd;
}

