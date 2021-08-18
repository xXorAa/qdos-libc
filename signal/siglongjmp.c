/*
 *      s i g l o n g j m p
 *
 *  POSIX compatible routine to handle signal
 *  state preserving variety of longjmp().
 *
 *  AMENDMENT HISTORY
 *  ~~~~~~~~~~~~~~~~~
 *  24 Jan 94   DJW   - First version.
 *  14 Feb 95    RZ
 */

#include <signal.h>
#include <sys/signal.h>
#include <setjmp.h>

void siglongjmp (sigjmp_buf env, int val)
{
    if (env->sigmask) 
    {
        (void)sigprocmask(SIG_SETMASK,(sigset_t *)&(env->sigmask),NULL);
    }
    (void) sigcleanup();
    longjmp(env->jmp, val);
    return;
}
