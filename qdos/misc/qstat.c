/*
 *          q s t a t
 *
 *  Routine to get the file information from
 *  QDOS, given a file name.
 *
 *  This is effectively similar to the unix 'stat'
 *  call except that the data is returned in the
 *  format of a QL directory entry rather than
 *  a 'stat' structure.
 *
 *  AMENDMENT HISTORY
 *  ~~~~~~~~~~~~~~~~~
 *  22 Aug 92   DJW   - Removed setting of errno and _oserr.  Changed
 *                      return values appropriately.
 *
 *  14 Oct 93   DJW   - Changed to use support routine _fqstat() when working
 *                      on names (e.g. FLP1_) that are simply devices).
 */

#define __LIBRARY__

#include <qdos.h>
#include <fcntl.h>
#include <string.h>
#include <unistd.h>

int qstat  _LIB_F2_ ( char *,           name,
                      struct qdirect *, dstat)
{
    int fd;
    int ret;
    chanid_t chid;

    if((fd = open( name, O_RDONLY)) >= 0) {
        ret = fqstat( fd, dstat);
        (void) close( fd );
        return ret;
    }
    /*
     *  This allows for names that are merely the device name
     */
    if ((strchr(name,'_') == &name[strlen(name)-1])
    &&  (isdirdev(name) != 0)
    &&  ((chid = io_open (name, 4)) > 0) ) {
        ret = _fqstat( chid, dstat);
        dstat->d_type = QF_DIR_TYPE;          /* Ensure set as directory */
        (void) io_close( chid );
        return ret;
    }
    return -1;
}

