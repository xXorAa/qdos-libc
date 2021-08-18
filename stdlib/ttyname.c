/*
 *      t t y n a m e
 *
 *  Unix compatible routine to get the name of a channel.
 *
 *  If we opened it outself, then we should have stored
 *  the name.  If the channel was opened in another
 *  program, then we do not have the name.  In a future
 *  version of this routine it may be possible to make
 *  it more sophisticated and search the QDOS structures
 *  to get the name, but at the moment we just return
 *  a standard default value.
 *
 *  AMENDMENT HISTORY
 *  ~~~~~~~~~~~~~~~~~
 *  12 Nov 95   DJW   - First version
 */

#define __LIBRARY__

#include <stdlib.h>
#include <fcntl.h>


char * ttyname _LIB_F1_ (int,  fd)
{
    UFB_t * uptr;
    /*
     *  Start with a sanity check
     */
    if ( (uptr = _Chkufb( fd )) == NULL) {
        return NULL;
    }
    return (uptr->ufbnam == NULL ? "<unknown>" : uptr->ufbnam);
}
