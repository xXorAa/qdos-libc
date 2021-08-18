/*
 *      f c h m o d
 *
 *  UNIX compatible routine for setting file access permissions
 *  given a file descriptor.
 *
 *  In practise on QDOS, the concept of user-id and group-id do not
 *  exists, so we ignore those bits.  Also, the concept of read/write
 *  bits are ignored as we cannot make a file read or write only.
 *  The execute bit is used to set the program as EXEC/able (or not).
 *
 *  AMENDMENT HISTORY
 *  ~~~~~~~~~~~~~~~~~
 *  16 Oct 93   DJW   - First version
 */

#include <sys/stat.h>
#include <errno.h>
#include <fcntl.h>
#include <unistd.h>
#include <qdos.h>

int fchmod  (fd, mode)
  int     fd;
  mode_t  mode;
{
    struct qdirect header;
    struct stat sbuf;
    chanid_t chid;

    /*
     *  Check that file exists
     */
    if (fstat(fd, &sbuf) < 0) {
        /* errno will be set by fstat() call */
        return -1;
    }
    /*
     *  Even execute bits mean nothing if it is a directory,
     *  So we make certain all such calls succeed.
     */
    if (sbuf.st_mode & S_IFDIR) {
        return 0;
    }
    /*
     *  Read the file header
     */
    if ((chid = getchid(fd)) < 0) {
        errno = EBADF;
        return -1;
    };
    (void) fs_headr(chid, (timeout_t)-1, &header, sizeof(header));
    /*
     *  Set the file type according to the
     *  mode requested
     */
    header.d_type= (mode & (S_IXUSR | S_IXGRP | S_IXOTH))
                    ? (char)QF_PROG_TYPE : (char)QF_DATA_TYPE;
    /*
     *  Write the file header back
     */
    (void) fs_heads(chid, (timeout_t)-1, &header, sizeof(header));
    return 0;
}

