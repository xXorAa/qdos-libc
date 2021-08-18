/*
 *      f p a t h c o n f
 *
 *  Posix compatible routine to get configuration details on a file
 *
 *  AMENDMENT HISTORY
 *  ~~~~~~~~~~~~~~~~~
 */

#define __LIBRARY__

#include <unistd.h>
#include <errno.h>
#include <fcntl.h>
#include <qdos.h>

long    fpathconf (fd, action)
  int fd;
  int action;
{
    (void) fd;              /* dummy to suppress compiler warning */
    (void) action;

    errno = EINVAL;
    return -1L;

#if 0
    struct UFB * uptr;

    /*
     *  Check that the file is open
     *  and get the unix file structure
     */
    if((uptr = _chkufb(fd)) == NULL) {
        /* errno set by this point */
        return -1;
    }
    switch (action) {
    case _PC_LINK_MAX:
                return 1;

    case _PC_MAX_CANON:
    case _PC_MAX_INPUT:
                return -1;

    case _PC_NAME_MAX:
    case _PC_PATH_MAX:
                return 
    case _PC_PIPE_BUF:
    case _PC_CHOWN_RESTRICTED:

    }
#endif
}

