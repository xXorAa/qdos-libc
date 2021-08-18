/*
 *      s i g a c t i o n
 *
 *  POSIX compatible routine to examine
 *  and change signal action
 *
 *  AMENDMENT HISTORY
 *  ~~~~~~~~~~~~~~~~~
 *  24 Jan 94   DJW   - First version.
 *
 *  25 Feb 95   RZ    - Complete rewrite
 *
 *  15 May 95   RZ    - Use _sigves instead of _sigh.sigvec
 */

#include <signal.h>
#include <sys/signal.h>
#include <errno.h>
#include <qdos.h>

int sigaction (signo, act, oact)
  int signo;
  struct sigaction *act;
  struct sigaction *oact;
{
#ifdef SIGDEBUG
    sigprintf("\tcalling sigaction: signo=%d\t\n",signo);
    if (act) 
        sigprintf("new handler: %d, sa_mask=%d, flags=%d\n",
                        act->sa_handler,act->sa_mask,act->sa_flags);
#endif /* SIGDEBUG */
    _oserr = (*(_sigvec))(_sigch,1,signo,act,oact);
#ifdef SIGDEBUG
    sigprintf("\t\t sigaction result : %d\n",_oserr);
    if (oact) 
        sigprintf("old handler: %d, sa_mask=%d, flags=%d\n",
                        oact->sa_handler,oact->sa_mask,oact->sa_flags);
#endif /* SIGDEBUG */

    if (_oserr==0) 
        return 0;
    errno=(_oserr==ERR_OR ? ERANGE : EOSERR);
    return (int)SIG_ERR;
}

