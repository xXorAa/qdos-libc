/*
 *      _ M o d e F d
 *
 *  Support routine that converts between
 *  the UFB modes and the Level 1 I/O modes.
 *
 *  AMENDMENT HISTORY
 *  ~~~~~~~~~~~~~~~~~
 *  12 Nov 95   DJW   - First version.  Introduced while tidying up the
 *                      handling within the library of the O_NONBLOCK flag.
 */

#define __LIBRARY__

#include <fcntl.h>

/*
 *  Translate between UFB file level
 *  flags and level 1 file flags
 */
int    _ModeFd _LIB_F1_ (short,  mode)
{
    struct _MODE_TABLE *pTrans;
    short  ret;

    for (ret=0, pTrans=&_ModeTable[0]; pTrans->ufbflag ; pTrans++)
    {
        if ((mode & pTrans->ufbflag) == pTrans->ufbflag)
        {
            ret |= pTrans->fileflag;
            mode &= (short)~((short)pTrans->ufbflag);
        }
    }
    return ((int)ret);
}

