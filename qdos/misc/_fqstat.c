/*
 *          f q s t a t
 *
 *  Get the file information from QDOS, given a 
 *  level 1 file descriptor.
 *  (QDOS specific instance of fstat)
 *
 *  Returns:
 *          0   Success
 *          -1  Failure.  Details given by errno and _oserr variables
 *
 *  AMENDMENT HISTORY
 *  ~~~~~~~~~~~~~~~~~
 *  11 Jul 93   DJW     Removed assumption that fs_headr() sets _oserr
 *
 *  22 Aug 93   DJW     Removed setting of _oserr and changed return
 *                      values appropriately.
 *
 *  14 Oct 93   DJW     Made into a support routine used by both qstat()
 *                      and fqstat().  Takes chanid instead of fd as a
 *                      parameter.
 */

#define __LIBRARY__

#include <qdos.h>

int  _fqstat  _LIB_F2_ (chanid_t,         chid,
                        struct qdirect *, stat)
{
    int reply;

    if ((reply = fs_headr( chid, (timeout_t)-1L, (char *)stat, 
                    (long)sizeof( struct qdirect ))) >= 0) {
        reply = 0;
    }
    return (reply);
}

