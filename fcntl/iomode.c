/*
 *          i o m o d e
 *
 * Routine to change the i/o mode of a level 1
 * file. Exclusive OR's the current flags in
 * the ufb structure with the passed flags.
 * Returns the previous value of the flags, so
 * if 0 is passed in the mode field then no
 * change is made to the flags field, it is
 * just returned unchanged.
 */

#include <fcntl.h>

int iomode( fd, mode)
int fd, mode;
{
    int flags;

    /* Get the old flags field */
    if(( flags = fcntl( fd, F_GETFL, 0))==-1)
        return -1;
    if(( fcntl( fd, F_SETFL, flags ^ mode)) == -1)
        return -1;
    return flags;
}

