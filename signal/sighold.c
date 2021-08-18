/*
 *      s i g h o l d
 *
 *  Unix SVR4 routine to add a signal to the current signal mask
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

int sighold (signo)
  int        signo;
{
  sigset_t set;

  set = sigmask(signo);
  (void) sigprocmask(SIG_BLOCK,&set,NULL);

  return 0;
}

