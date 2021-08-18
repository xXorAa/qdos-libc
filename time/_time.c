/*
 *              t i m e
 *
 * Standard routine to get time in UNIX format by reading the
 *  QDOS clock and converting the base start time
 */

#define __LIBRARY__

#include <qdos.h>
#include <time.h>

time_t time  _LIB_F1_ ( time_t *,  tv)
{
    time_t  t = mt_rclck();

    t = TIME_QL_UNIX(t);
    if( tv ) {
        *tv = (time_t)t;
    }
    return (time_t)t;
}

