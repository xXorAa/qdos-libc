/*
 *      s t i m e
 *
 *  Unix compatible routine for setting the system time.
 *
 *  AMENDMENT HISTORY
 *  ~~~~~~~~~~~~~~~~~
 *  02 Apr 94   DJW   - First version
 */

#define __LIBRARY__

#include <qdos.h>
#include <unistd.h>

int stime _LIB_F1_(const time_t *,  tp)
{
    mt_sclck (TIME_UNIX_QL(*tp));
    return 0;
}


