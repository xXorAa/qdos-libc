/*
 *      s i g p e n d i n g
 *
 *  POSIX compatible routine to
 *  examine pending signals.
 *
 *  AMENDMENT HISTORY
 *  ~~~~~~~~~~~~~~~~~
 *  24 Jan 94   DJW   - First version.
 *  14 Feb 95    RZ
 *  15 May 96    RZ   - Changed to use sigvec
 *
 */

#include <signal.h>
#include <sys/signal.h>

int sigpending (set)
  sigset_t *set;
{
    (void) (*_sigvec)(_sigch,3,set);
    return 0;
}

