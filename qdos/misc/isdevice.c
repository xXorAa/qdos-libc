/*
 *      i s d e v i c e
 *
 * Routine to check if a string starts with a
 * device name.
 *
 * Returns TRUE if it is, with extra info in the
 * int parameter passed as well as the name.
 *
 * Actually searches system lists.
 *
 * AMENDMENT HISTORY
 * ~~~~~~~~~~~~~~~~~
 *  10 Jul 93   DJW     Removed assumption that io_close() sets _oserr.
 *
 *  14 Jan 95   DJW   - Missing 'const' keyword added to function definition.
 */

#define __LIBRARY__

#include <qdos.h>

int  isdevice _LIB_F2_ (const char *,   str, \
                        int  *,         extra)
{
    if ((*extra = isdirdev(str)) == 0) {
        chanid_t chid;
        /*
         *  Check for simple device by trying to
         *  open device (closed immediately if works).
         */
        if ((chid = io_open( str, 0 )) >= 0) {
            (void) io_close(chid);
        } else {
            switch (chid) {
            case ERR_IU:
            case ERR_EX:
                break;
            default:
                return 0; /* Device not found */
            }
        }
    }
    return 1;
}

