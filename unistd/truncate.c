/*
 *  t r u n c a t e
 *
 * Unix compatible routine to truncate a file at a length
 * given a file name.
 */

#include <unistd.h>
#include <fcntl.h>

int truncate( name, length)
char *name; /* File name */
off_t length; /* New length for file (must be shorter than current length) */
{
    int fd, ret;

    if((fd = open( name, O_RDWR)) == -1) {
        return -1;
    }
    ret = ftruncate( fd, length);
    (void) close( fd );
    return ret;
}

