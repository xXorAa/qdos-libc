/*
 *      s i g d e l s e t
 *
 *  POSIX compatible routine to delete
 *  a signal from a signal set
 *
 *  AMENDMENT HISTORY
 *  ~~~~~~~~~~~~~~~~~
 *  24 Jan 94   DJW   - First version.
 *   7 Feb 95    RZ   - changed to use sigmask()
 */

#include <signal.h>
#include <sys/signal.h>
#include <errno.h>

int sigdelset (set, signo)
  sigset_t * set;
  int        signo;
{
    if (signo < 1  || signo > _NSIG) 
    {
        errno = EINVAL;
        return -1;
    }
    *set &= ~sigmask(signo);
    return 0;
}
