/*
 *      c h m o d
 *
 *  UNIX compatible routine for setting file access permissions
 *  given the file name.
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

#define __LIBRARY__

#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>
#include <qdos.h>

int chmod   (path, mode)
  const char *  path;
  mode_t  mode;
{
    struct qdirect header;
    struct stat sbuf;
    int     fd;
    chanid_t chid;

    /*
     *  Check that file exists
     */
    if (_Stat(path, &sbuf) < 0) {
        /* errno will be set by stat() call */
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
     *  We now need to open the file
     *  (Unlike unix, we could get a failure here)
     */
    if ((fd = open(path, O_RDONLY)) < 0) {
        /* errno will be set by open() call */
        return -1;
    }
    /*
     *  Read the file header
     */
    chid = getchid(fd);
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
    /*
     *  Tidy up and return to user
     */
    (void) close(fd);
    return 0;
}

