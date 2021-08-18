/*
 *              l s e e k
 *
 *  Unix compatible routine to handle positioning
 *  on all the different types of device. 
 *
 *  AMENDMENT HISTORY
 *  ~~~~~~~~~~~~~~~~~
 *  21 Jun 93   DJW   - Removed assumption that fs_pos() routine would set
 *                      the global variable _oserr - instead assumes that
 *                      it returns an error code if anything goes wrong.
 *
 *  22 Sep 95   DJW   - Corrected fact that seeks beyond the end of file
 *                      should extend the file.  They were just seeking to
 *                      the previous end of file and returning that value.
 */

#define __LIBRARY__

#include <unistd.h>
#include <qdos.h>
#include <fcntl.h>
#include <errno.h>

long lseek  _LIB_F3_ ( int,     fd,         \
                       long,    offset,     \
                       int,     mode)
{
    struct UFB *uptr;
    long wanted_pos;
    long pos;
    int  reply;

    /*
     *  Start with sanity checks
     */
    if(!(uptr = _Chkufb(fd)))
        return -1L;

    /*
     *  Ensure that this is a directory type device
     *  as no seek on non-disk types
     */
    if(uptr->ufbtyp != D_DISK) {
        errno = ESPIPE;
        return -1L;
    }
    /*
     *  Get desired position, realising that
     *  QDOS does not let you seek past the
     *  end of a file.
     */
    wanted_pos = fs_pos (uptr->ufbfh, 0L, mode) + offset;
    /*
     *  Now try to position as requested
     */
    if (((pos = fs_pos( uptr->ufbfh, offset, mode)) < 0)
    &&   (pos != ERR_EF) ) {
        _oserr = (int)pos;
        errno = EOSERR;
        return -1L;
    }
    /*
     *  If we are short of desired position, this must
     *  be because the file is to small, so extend it.
     *  Note that we could run out of space trying to
     *  extend the file, which would cause an error
     *  return to be made.
     */
    while (pos++ < wanted_pos) {
        if ((reply = io_sbyte (uptr->ufbfh, (timeout_t)-1, (unsigned char)0)) < 0) {
            _oserr = reply;
            errno = EOSERR;
            return -1L;
        }
    }

    return wanted_pos;
}

