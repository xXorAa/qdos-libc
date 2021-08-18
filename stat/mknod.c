/*
 *      m k n o d
 *
 *  Unix compatible call to create a directory, standard file or
 *  a special file.
 *
 *  As QDOS and SMS do not support the Unix concept of special files,
 *  any attempt to create such a file causes an error return.  Attempts
 *  to create a standard file or a directory are accepted however.
 *
 *  AMENDMENT HISTORY
 *  ~~~~~~~~~~~~~~~~~
 *  21 Aug 94   DJW   - First version
 */

#define __LIBRARY__

#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <errno.h>
#include <unistd.h>

int  mknod (const char * path, mode_t mode, dev_t dev)
{
    struct stat buf[1];
    int     fd;


    (void) dev;     /* Dummy to stop compiler warning about unused variable */

    /*
     *  Start by checking that the file does not already exist
     */
    if (_Stat(path, buf) == 0) {
        errno = EEXIST;
    } else {
        switch (mode & S_IFMT) {

        case S_IFDIR:
                /*
                 *  If a directory is required, then exit via
                 *  the create directory routine
                 */
                return mkdir(path, mode & (S_ISUID | S_ISGID | S_ISVTX | S_IRWXU | S_IRWXG | S_IRWXO));
        
        case S_IFREG:
                /*
                 *  If it is a standard file, then simply try and
                 *  open (and then close) the new file
                 */
               if ((fd=open(path,O_WRONLY | O_CREAT | O_EXCL)) == -1) {
                    return -1;
                }
                (void) close (fd);
                return 0;

        default:
                /*
                 *  If the file is not a standard file or a directory, then
                 *  make an error return as QDOS and SMS do not handle other types.
                 */
                errno = EINVAL;
                break;
        }
    }
    return -1;
}

