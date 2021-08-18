/*
 *      d i f f t i m e
 *
 *  ANSI compatible routine to calculate the difference
 *  between two times.
 *
 *  This routine might seem pointless as the user could do the
 *  calculation, but its purpose is to allow for the fact that the
 *  user should never need to know the internal representation
 *  of the "time_t" variable type.
 *
 *  AMENDMENT HISTORY
 *  ~~~~~~~~~~~~~~~~~
 *  29 Aug 93   DJW   - First Version
 */

#define __LIBRARY__

#include <time.h>

double difftime _LIB_F2_(time_t,    time1,      \
                         time_t,    time2)
{
    return((double)( time1 - time2 ));
}

