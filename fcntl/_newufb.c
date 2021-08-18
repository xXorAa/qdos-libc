/*
 *                  _ n e w u f b
 *
 * Routine that checks that a UFB exists for a given
 * file descriptor.  If the current table is full, it
 * will attempt to extend it.
 *
 * Returns a pointer to the UFB on sucess,
 *          NULL if unable to extend table.
 *
 * No checks are done on UFB contents (c.f. chkufb).
 *
 * Used by the level 1 I/O functions.
 *
 * CAUTION.
 * Can cause the UFB table to move in memory.
 */

#define __LIBRARY__

#include <fcntl.h>
#include <stdlib.h>
#include <string.h>
#include <errno.h>

struct UFB *_Newufb(fd)
int fd;
{
    struct UFB *up;
    int     count = fd + 1;

    if (fd < 0)
    {
        /* Handle not in range */
        errno = EINVAL;
        return (struct UFB *)NULL;
    }

    if (count > _nufbs)
    {
        /*
         *  Try and extend the UFB table
         */
        if (!(up = (struct UFB *) realloc ((void *)_ufbs, 
                                          (size_t)(count * sizeof(struct UFB)))))
        {
            errno = ENOMEM;
            return (struct UFB *)NULL;
        }
        /*
         *  got memory, so finish setup
         */
        _ufbs = up;
        (void) memset((void *)&up[_nufbs], 0, 
                            (size_t)((count - _nufbs) * sizeof(struct UFB)));
        _nufbs = count;
    }
    return &_ufbs[fd];
}

