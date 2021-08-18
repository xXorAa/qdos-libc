/*
 *      s i g s e t j m p
 *
 *  POSIX compatible routine to handle signal
 *  state preserving variety of setjmp().
 *
 *  AMENDMENT HISTORY
 *  ~~~~~~~~~~~~~~~~~
 *  24 Jan 94   DJW   - First version.
 *  14 Feb 95    RZ
 */

#include <signal.h>
#include <sys/signal.h>
#include <setjmp.h>

int sigsetjmp (sigjmp_buf  env, int savemask)
{
    if (savemask)
    {
      (void) sigprocmask(SIG_SETMASK,NULL,(sigset_t *)&(env->sigmask));
    }
    else
    {
      env->sigmask = 0;
    }

    return (setjmp(env->jmp));
}
