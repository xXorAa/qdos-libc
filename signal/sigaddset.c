/*
 *      s i g a d d s e t
 *
 *  POSIX compatible routine to add
 *  a signal to a signal set
 *
 *  AMENDMENT HISTORY
 *  ~~~~~~~~~~~~~~~~~
 *  24 Jan 94   DJW   - First version.
 *   7 Feb 95   RZ    - changed to use SIGMASK()
 */

#include <signal.h>
#include <sys/signal.h>
#include <errno.h>

int sigaddset (set, signo)
  sigset_t * set;
  int        signo;
{
    if (signo < 1  || signo > _NSIG) 
    {
        errno = EINVAL;
        return -1;
    }
    *set |= sigmask(signo);
    return 0;
}
