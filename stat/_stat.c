/*
 *                s t a t
 *
 *  Unix compatible routine to get the file information
 *  from QDOS in UNIX format, given a file name.
 *
 *  AMENDMENT HISTORY
 *  ~~~~~~~~~~~~~~~~~
 *  14 Oct 93   DJW   - Changed to use _fstat() support routine.
 *                    - Changed to allow for directories to be specified
 *                      as well (or raw devices).
 *
 *  28 Dec 93   DJW   - Amended to incorporate some new ideas from the code
 *                      provided by Eric Slagter.
 *
 *  28 May 94   DJW   - Now put value returned by _fstat() into errno, and
 *                      test result to return 0 or -1.  This allows the
 *                      _fstat routine to be put into a RLL library.
 */

#define __LIBRARY__

#include <qdos.h>
#include <errno.h>
#include <fcntl.h>
#include <string.h>
#include <unistd.h>
#include <sys/stat.h>


int  _Stat   _LIB_F2_(const char *,     name,   \
                      struct stat *,    buf)
{
    int         fd, ret;
    chanid_t    chid;

    /*
     *  Many of the device drivers under QDOS will not allow
     *  a standard open on a name which is merely a device
     *  name (such as FLP1_, or RAM1_).  We need to do a
     *  directory mode open on such devices instead.
     *
     *  However, we also have to allow for the fact that many
     *  drivers will allow a directory open on a name that
     *  starts with a device or directory name.  As an example,
     *  trying to open RAM1_TEST will succeed in opening RAM1_
     *  if the file TEST_ does not exist!.  We therefore need
     *  to do a validity check that if there is an underscore in
     *  the name there is only one and it is the last character.
     *
     *  NOTE.  We cannot do a stat() call on a file with a name
     *         of zero length even though some QDOS drivers allow
     *         it as the directory mode will succeed in preference.
     */
    if (strpos(name, '_') == strlen(name) - 1)
    {
        if ((chid = io_open (name, DIROPEN)) > 0)
        {
            ret = _Fstat (chid, buf);
            buf->st_mode |= S_IFDIR;            /* Ensure set as directory */
            (void) io_close( chid );
            if (ret != 0)
            {
                errno = ret;
                return -1;
            }
            return 0;
        }
    }
    /*
     *  It is not a special case, so try a standard
     *  type of open in read only mode
     */
    if( (fd = open( name, O_RDONLY)) >= 0)
    {
        ret = fstat( fd, buf);
        (void) close( fd );
        if (ret != 0)
        {
            errno = ret;
            return -1;
        }
        return 0;
    }
    /*
     *  If all this fails, then we are going
     *  to have to make an error return.
     */
    errno = ENOENT;
    return -1;
}

