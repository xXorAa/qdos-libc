#ifndef _SYS_TIME_H
#define _SYS_TIME_H

/*
 *  < s y s / t i m e . h>
 *
 *
 *  AMENDMENT HISTORY
 *  ~~~~~~~~~~~~~~~~~
 *  15 Dec 96   DJW   - First version.
 *  09 Aug 98   JH    - change for select() in libsocket.a
 */

#ifndef _SYS_TYPES_H
#include <sys/types.h>
#endif

#include <time.h>

struct timeval {
        int tv_sec;
        int tv_usec;
    };

#ifdef __STDC__
#define _P_(params) params
#else
#define _P_(params) ()
#endif

#include <sys/select.h>
      
#undef _P_

#endif  /* _SYS_TIME_H */
