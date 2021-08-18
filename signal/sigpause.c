/*
 *      s i g p a u s e
 *
 *  Unix SVR4 routine to delete a signal to the current signal mask,
 *  and then suspend waiting for a signal
 *
 *  AMENDMENT HISTORY
 *  ~~~~~~~~~~~~~~~~~
 *  24 Mar 94   DJW   - First version.
 *  14 Feb 95    RZ
 */

#include <signal.h>
#include <sys/signal.h>

int sigpause (signo)
  int        signo;
{
    sigset_t set;

    set=sigmask(signo);
    (void) sigprocmask(SIG_UNBLOCK,&set,NULL);
    (void) sigprocmask(0,NULL,&set);

    (void) sigsuspend (&set);
    return 0;
}
