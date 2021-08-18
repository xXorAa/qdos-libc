/*
 *      s i g r e l s e
 *
 *  Unix SVR4 routine to delete a signal to the current signal mask
 *
 *  sigset() family
 *
 *  AMENDMENT HISTORY
 *  ~~~~~~~~~~~~~~~~~
 *  24 Mar 94   DJW   - First version.
 *  14 Feb 95    RZ
 */

#include <signal.h>
#include <sys/signal.h>

int sigrelse (signo)
  int        signo;
{
  sigset_t set;

  set = sigmask(signo);
  (void) sigprocmask(SIG_UNBLOCK,&set,NULL);

  return 0;
}
