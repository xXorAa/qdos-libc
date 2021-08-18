/*
 *      _ G e t T i m o u t
 *
 *  Get the timeout for a channel taking into account whether it
 *  currently has the UFB_ND or UFB_NB flags set.
 *
 *  AMENDMENT HISTORY
 *  ~~~~~~~~~~~~~~~~~
 *  12 Nov 95   DJW   - First version
 */

#define __LIBRARY__

#include <fcntl.h>

timeout_t   _GetTimeout _LIB_F1_(UFB_t *,  uptr)
{
    return (timeout_t)((uptr->ufbflg & (UFB_ND| UFB_NB)) ? 0 : _Timeout);
}

