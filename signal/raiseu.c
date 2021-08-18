/*
 *          r a i s e u
 *
 *  routine to raise a signal for the current process
 *  and pass additional information with it
 *
 *  AMENDMENT HISTORY
 *  ~~~~~~~~~~~~~~~~~
 *  14 Feb 95    RZ
 *
 *  15 May 95    RZ        - Changed to use _sigvec
 */

#include <signal.h>
#include <sys/signal.h>
#include <unistd.h>

int raiseu (sigval,uval)
  int sigval,uval;
{
   /* return ( (kill((int)getpid(),sigval) == -1) ? -1 : 0); */
   /* if( sigval<1 || sigval>_NSIG ) return -1; */

#ifdef SIGDEBUG
   sigprintf("calling raiseu %d, %d\n",sigval,uval);
#endif
   return (*_sigvec)(_sigch,4,sigval,uval);
}

