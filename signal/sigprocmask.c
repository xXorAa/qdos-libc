/*
 *      s i g p r o c m a s k
 *
 *  POSIX compatible routine to examine and change blocked signals.
 *
 *  AMENDMENT HISTORY
 *  ~~~~~~~~~~~~~~~~~
 *  24 Jan 94   DJW   - First version.
 *  14 Feb 95    RZ
 *  15 May 96    RZ   - Changed to use _sigvec
 *
 */

#include <errno.h>
#include <qdos.h>
#include <signal.h>
#include <sys/signal.h>

int sigprocmask (how, set, oset)
  int how;
  sigset_t * set;
  sigset_t * oset;
{
    /*
     *  If 'oset' is not a NULL pointer, the previous mask
     *  is stored in the location to which it points.
     */
    /*
     *  If 'set' is a NULL pointer, then the value of the
     *  'how' parameter is irrelevant, and the mask is unchanged.
     */

#ifdef SIGDEBUG
static char *show[]={"BLOCK","UNBLOCK","SETMASK"};

    sigprintf("calling sigprocmask, %s\n",show[how]);
    if (set) 
        sigprintf("\t set-mask %x\n",*set);
#endif /* SIGDEBUG */

    _oserr = (*_sigvec)(_sigch,2,how,set,oset);

#ifdef SIGDEBUG
    if (oset) 
        sigprintf("\t oldmask %x\n",*oset);
#endif /* SIGDEBUG */

    return (_oserr ? errno=EOSERR,-1 : 0);

}

