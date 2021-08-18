/*
 *          i s n o c l o s e
 *
 * Routine to check if a channel was passed on
 * the stack before execution (set no close).
 *
 * AMENDMENT HISTORY
 * ~~~~~~~~~~~~~~~~~
 */

#define __LIBRARY__

#include <qdos.h>
#include <fcntl.h>

int  isnoclose  _LIB_F1_( int,  fd)
{
    struct UFB *uptr;

    if(!(uptr = _Chkufb(fd)))
        return -1;

    return ( uptr->ufbflg & UFB_NC );
}

