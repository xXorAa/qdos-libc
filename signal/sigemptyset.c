/*
 *      s i g e m p t y s e t
 *
 *  POSIX compatible routine to set up an empty set of signals
 *
 *  AMENDMENT HISTORY
 *  ~~~~~~~~~~~~~~~~~
 *  24 Jan 94   DJW   - First version.
 */

#include <signal.h>

int sigemptyset (set)
  sigset_t  *set;
{
    *set = 0;
    return 0;
}


