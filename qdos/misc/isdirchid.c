/*
 *      i s d i r c h i d
 *
 *  Routine to determine if a given channel belongs to a directory
 *  device or not.   
 *
 *  Returns:
 *          Failure     NULL
 *          Success     Pointer to Directory Device Driver Defintion Block
 *
 * AMENDMENT HISTORY
 * ~~~~~~~~~~~~~~~~~
 *  25 Nov 93   DJW   - First Version
 */

#define __LIBRARY__

#include <qdos.h>
#include <channels.h>

struct QLDDEV_LINK * isdirchid _LIB_F1_ (chanid_t,  chid)
{
    struct chan_defb *   cdefb;
    struct QLDDEV_LINK * qddev;

    _super();
    /*
     *  Get the channel address.
     *
     *  If fail to get it then this was not
     *  a correct channel id, so cannot
     *  belong to a directory device.
     */
    if ((long)(cdefb = _getcdb(chid)) <= 0) {
        qddev = NULL;
    } else {
        qddev = _isfscdb(cdefb);
    }
    _user();
    return qddev;
}

