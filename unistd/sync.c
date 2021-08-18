/*
 *      s y n c
 *
 *  Unix compatible routine to update the filing system 'super block'
 *
 *  There is no direct equivalent in QDOS or SMS, so we treat this call
 *  as a dummy.   What we would like to do is force a flush of all the
 *  slave blocks held in memory, but there is not (as far as I knwo) a
 *  generic way of doing this.
 *
 *  AMENDMENT HISTORY
 *  ~~~~~~~~~~~~~~~~~
 *  21 Aug 94   DJW   - First version
 */

#include <unistd.h>

void  sync (void)
{
    return;
}

