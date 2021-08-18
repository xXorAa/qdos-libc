/*
 *      c l o c k
 *
 *  ANSI defined function to get process processor time.
 *
 *  If not supported, then -1 is returned.
 *
 *  AMENDMENT HISTORY
 *  ~~~~~~~~~~~~~~~~~
 *  28 Aug 93   DJW   - First version
 */

#include <time.h>

clock_t clock (void)
{
    return (clock_t)-1;
}

