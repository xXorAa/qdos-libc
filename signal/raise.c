/*
 *          r a i s e
 *
 *  ANSI compatible routine to raise a signal for
 *  the current process (this program).
 *
 *  AMENDMENT HISTORY
 *  ~~~~~~~~~~~~~~~~~
 *  14 Feb 95    RZ
 *
 *  15 May 96    RZ        - Changed to use _sigvec
 */

#include <signal.h>
#include <sys/signal.h>
#include <unistd.h>

int raise (sigval)
  int sigval;
{
#ifdef SIGDEBUG
   sigprintf("calling raise %d \n",sigval);
#endif

   return (*_sigvec)(_sigch,4,sigval,0);
}

