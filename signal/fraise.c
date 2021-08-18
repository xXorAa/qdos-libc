/*
 *          f r a i s e
 *
 *  routine to immediately raise a signal
 *
 *
 *  AMENDMENT HISTORY
 *  ~~~~~~~~~~~~~~~~~
 *  14 Feb 95    RZ
 *
 *  15 May 95    RZ   Changed to use _sigvec
 */

#include <signal.h>
#include <sys/signal.h>
#include <unistd.h>


/* imediately raise, disregard all blocking conditions */
int fraise (sigval,uval)
  int sigval,uval;
{

#ifdef SIGDEBUG
   sigprintf("calling fraise %d, %d\n",sigval,uval);
#endif
   return (*_sigvec)(_sigch,5,sigval,uval);
}

