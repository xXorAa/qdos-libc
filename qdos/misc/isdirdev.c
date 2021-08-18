/*
 *      i s d i r d e v
 *
 * Routine to check if a string starts with a 
 * directory device name.
 *
 * Returns:
 *      0   if false
 *      , and positive value
 *
 * Actually searches system lists.
 *
 * AMENDMENT HISTORY
 * ~~~~~~~~~~~~~~~~~
 *  14 Oct 93   DJW   - Redid test against device name for additional speed
 *
 *  06 Sep 94   DJW   - Removed call to mt_inf().  Used global '_jobid'
 *                      variable instead.
 *
 *  14 Jan 95   DJW   - Missing 'const' keyword added to function definition.
 */

#define __LIBRARY__

#include <qdos.h>
#include <ctype.h>
#include <string.h>

int  isdirdev _LIB_F1_ ( const char *,  str)
{
    const char    *ptr, *ptr2;
    short len;
    struct QLDDEV_LINK  *ldd;

    if (str == NULL  || *str == 0)
        return (0);
    /*
     *  Ensure no changes in list while we search
     */
    _super();
    /*
     *  Search the system directory device lists until we get
     *  a match, or have run out of names
     */
    for( ldd = *(struct QLDDEV_LINK **)( _sys_var + 0x48); ldd; ldd = ldd->ldd_next) {
        for (ptr = str, ptr2 = ldd->ldd_dname.qs_str, len=ldd->ldd_dname.qs_strlen ; 
                    len ; ptr++, ptr2++, len--) {
            if ((char)(*ptr | (char)0x20) != (char)(*ptr2  | (char)0x20)) {
                break;
            }
        }
        if (len == 0 && *ptr >= '1'  && *ptr <= '8'  && ptr[1] == '_') {
            break;
        }
    }
    _user(); /* Back to user mode */
    /*
     *  If we found no match, then cannot be a directory device
     */
    if( ldd == NULL ) {
        return 0;
    } 
    /*
     *  Check the network device case
     */
    if( *str == 'N' || *str == 'n' && ldd->ldd_dname.qs_strlen == 1) {
        return (DIRDEV | NETDEV);
    }
    return DIRDEV;
}

