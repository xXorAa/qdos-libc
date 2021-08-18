/*
 *      r m d i r
 *
 *  Unix/Posix compatible call to remove a directory.
 *
 *  This routine will only work on QDOS or SMS systems that have
 *  devices that support hard directories. 'Soft' directories as
 *  supported by Toolkit 2 cannot be removed using this call.
 *
 *  AMENDMENT HISTORY
 *  ~~~~~~~~~~~~~~~~~
 *  21 Aug 94   DJW   - First version
 */

#define __LIBRARY__

#include <unistd.h>
#include <errno.h>
#include <sys/stat.h>

int     rmdir (const char *path)
{
    struct stat buf[1];

    /*
     *  Check that file exists
     */
    if (_Stat(path,buf) != 0) {
        return -1;
    }
    /*
     *  Check that it is a directory
     */
    if ((buf->st_mode | S_IFDIR) == 0) {
        errno = ENOTDIR;
        return -1;
    }
    /*
     *  Exit via the delete routine
     */
    return unlink(path);

}

