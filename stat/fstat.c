/*
 *              f s t a t
 *
 *  Unix compatible routine to enquire on file status
 *  given a level 1 file descriptor.
 *
 *  AMENDMENT HISTORY
 *  ~~~~~~~~~~~~~~~~~
 *  14 Oct 93   DJW   - New version.  Most of logic of previous version now
 *                      in the support routine _fstat().
 *
 *  28 May 94   DJW   - Now put value returned by _fstat() into errno, and
 *                      test result to return 0 or -1.  This allows the
 *                      _fstat routine to be put into a RLL library.
 */

#define __LIBRARY__

#include <sys/stat.h>
#include <errno.h>
#include <fcntl.h>
#include <stddef.h>

int fstat (fd, buf)
  int  fd;
  struct stat * buf;
{
    struct UFB *        uptr;

    /*
     *  Get the pointer to the level 1 I/O structure
     */
    if(( uptr = _Chkufb( fd )) == NULL) {
        /*
         *  errno will already be set
         */
        return -1;
    }
    if ((errno = _Fstat(uptr->ufbfh, buf)) != 0) {
        return -1;
    }

    return 0;
}

