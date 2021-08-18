/*
 *      _ M o d e U f b
 *
 *  Support routines that converts between
 *  Level 1 I/O modes and UFB modes
 *
 *  AMENDMENT HISTORY
 *  ~~~~~~~~~~~~~~~~~
 *  12 Nov 95   DJW   - First version.  Introduced while tidying up the
 *                      handling within the library of the O_NONBLOCK flag.
 */

#define __LIBRARY__

#include <fcntl.h>

short  _ModeUfb _LIB_F1_ (int,  mode)
{
    struct _MODE_TABLE *pTrans;
    short  ret;

    for (ret=0, pTrans=&_ModeTable[0]; pTrans->ufbflag ; pTrans++)
    {
        if (((short)mode & (short)pTrans->modemask) == pTrans->fileflag)
        {
            ret |= pTrans->ufbflag;
            mode &= ~pTrans->fileflag;
        }
    }
    return (ret);
}

