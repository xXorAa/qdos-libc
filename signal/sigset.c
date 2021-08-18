/*
 *          s i g s e t
 *
 *  This routine emulates the Unix sigset() call
 *
 *  AMENDMENT HISTORY
 *  ~~~~~~~~~~~~~~~~~
 *  03 Apr 94   DJW   - First version
 *  14 Feb 95    RZ
 */

#include <signal.h>
#include <sys/signal.h>
#include <errno.h>

#ifdef __STDC__
#define _P_(params) params
#else
#define _P_(params)
#endif

void (*sigset (int signo, void (*function)_P_((int)))) _P_((int))
{
    struct sigaction act,oact;
    struct sigaction *pact;
    sigset_t set,oset,*pset;

    if (function == SIG_HOLD)
       {pact=NULL; pset=&set; set|=sigmask(signo);}
    else {
        pact=&act, pset=NULL;
        act.sa_handler=function;
        act.sa_mask=sigmask(signo);
        act.sa_flags=0;
         }

    (void) sigaction(signo,pact,&oact);
    (void) sigprocmask(SIG_BLOCK,pset,&oset);

    return ( oset&sigmask(signo) ? SIG_HOLD : oact.sa_handler);

}
