/*
 *          g e t c h i d
 *
 *  Get a QDOS channel id for level 1 files.
 */

#define __LIBRARY__

#include <qdos.h>
#include <fcntl.h>

chanid_t getchid  _LIB_F1_ ( int,   fd)
{
    struct UFB *uptr;

    if(!(uptr = _Chkufb(fd))) {
        return (chanid_t)-1L;
    }
    return uptr->ufbfh;
}

