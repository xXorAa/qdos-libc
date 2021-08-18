/*
 *              u t i m e
 *
 *  Routine to emulate the unix 'utime' system call that is used
 *  to set the file access and modification times.
 *
 *  In the case of QDOS, only the one time is maintained, so these
 *  are effectively the same field.   If both the file access
 *  time and modification time are set then the later of the two
 *  is taken.
 *
 *  AMENDMENT HISTORY
 *  ~~~~~~~~~~~~~~~~~
 *  27 Apr 94   DJW   - Amended to run correctly on systems that have
 *                      support for setting the dates via a TRAP call.
 *                      The previous simplistic method worked by manipulating
 *                      the system date which is a very untidy method if
 *                      it is not required.
 *                      Report and suggested fix from Richard Kettlewell
 *
 *  23 Feb 96   DJW   - Fixed problem where use on level 1 filing systems
 *                      could corrupt 1 byte of the file.
 */

#define __LIBRARY__

#include <utime.h>
#include <fcntl.h>
#include <errno.h>
#include <unistd.h>
#include <time.h>
#include <qdos.h>

int   utime   _LIB_F2_ ( char *,            filename,       \
                         struct utimbuf *,  times)
{
    time_t  newtime, savetime;
    unsigned long position;
    int     fd;
    char    ch;
    chanid_t chid;

    /*
     *  Start by ensuring that we can open this file
     */
    if ((fd = open (filename,O_RDWR)) <= 0 ) {
        errno = ENOENT;
        return (-1);
    }
    chid = getchid(fd);

    /*
     *  Start by calculating the time we need to set.
     *  As we are going to use low level QDOS calls,
     *  this needs to be in QDOS format.
     */
    newtime = (times == NULL) 
              ? 0
              : TIME_UNIX_QL(times->actime > times->modtime  \
                            ? times->actime                  \
                            : times->modtime);

    /*
     *  We next try to see if it this is a system that
     *  supports calls for setting the date.  If so, we
     *  use that method as being the most elegant.
     */
    if (fs_date(chid, (timeout_t)-1, 0, &newtime) == 0) {
        (void) close (fd);
        return 0;
    }

    /*
     *  It appears that the tidy method does not work!
     *  We therefore need to use an alternative method
     *  that involves forcing an updated status onto the
     *  file and then closing it while we (potentially)
     *  manipulate the system date.
     *
     *  Start by reading the first byte of the file.
     */

    switch (io_fbyte (chid, (timeout_t)-1, &ch)) {

    case 0:
            /*
             *  Normal case where we have simply read one byte OK
             *  Reset to to start and write the byte back.
             */
            position = 0L;
            (void) fs_posab (chid, (timeout_t)-1, &position);
            (void) io_sbyte (chid, (timeout_t)-1, ch);
            break;

    case ERR_EF:
            /*
             *  EOF encountered, so we have the special
             *  case of a zero length file.  We cannot
             *  force an update in this case by writing
             *  to it, so we delete the file and then
             *  re-create it.
             */
            (void) close (fd);
            (void) creat(filename, O_RDWR);
            break;

    default:
            /*
             *  Take error xit as the read failed for some reason!
             *  We assume that errno is already been set to say why.
             */
            (void) close(fd);
            return (-1);
    }
    /*
     *  When we close the file, the date set will correspond
     *  to the setting of the sytem clock at the point of close.
     */
    if (newtime == 0) {
        /*
         *  If we want the current time, simply close the file.
         */
        (void) close (fd);
        return 0;
    }
    /*
     *  Here comes the bad part!
     *
     *  We manipuluate the system clock to get
     *  the close() to hae the desired effect.
     */
    savetime = mt_rclck(); 
    mt_sclck (newtime);
    (void) close (fd);
    mt_sclck (savetime);
    return (0);
}

