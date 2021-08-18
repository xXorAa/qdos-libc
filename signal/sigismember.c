/*
 *      s i g i s m e m b e r
 *
 *  POSIX compatible routine to test
 *  for a signale in a signal set
 *
 *  AMENDMENT HISTORY
 *  ~~~~~~~~~~~~~~~~~
 *  24 Jan 94   DJW   - First version.
 *  14 Feb 95    RZ
 */

#include <errno.h>
#include <signal.h>
#include <sys/signal.h>

int sigismember (set, signo)
  sigset_t * set;
  int        signo;
{
    if (signo < 1  || signo > _NSIG) 
    {
        errno = EINVAL;
        return -1;
    }
    return ((*set & sigmask(signo)) ? 1 : 0);
}
