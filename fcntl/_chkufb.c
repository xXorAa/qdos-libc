/*
 *              _ C h k u f b
 *
 *  Routine to return an address of a UFB.  The
 *  following checks are done:
 *      a)  That the UFB exists
 *      b)  That it corresponds to an open file.
 *      c)  That the access mode bits required are set
 *  The timeout field is also set according to
 *  the delay mode.
 *
 * Used by the level 1 I/O functions.
 *
 * AMENDMENT HISTORY
 * ~~~~~~~~~~~~~~~~~
 *  26 Aug 93   DJW   - Removed setting of UFB timeout field.  Now done
 *                      in file opening code and program initialisation
 *                      code.
 */

#define __LIBRARY__

#include <fcntl.h>
#include <errno.h>
#include <stddef.h>

struct UFB *_Chkufb( fd )
int fd;
{
    struct UFB *uptr;

    if(( fd < 0) || (fd >= _nufbs))
    {
        /* Handle not in range */
        errno = EINVAL;
        return (NULL);
    }

    uptr = &_ufbs[fd];

    if((uptr->ufbflg & UFB_OP) == 0)
    {
        /* File is not open */
        errno = EBADF;
        return (NULL);
    }

    return uptr;
}

