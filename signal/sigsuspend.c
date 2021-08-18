/*
 *      s i g s u s p e n d
 *
 *  POSIX compatible routine to
 *  suspend and wait for a signal
 *
 *  AMENDMENT HISTORY
 *  ~~~~~~~~~~~~~~~~~
 *  24 Jan 94   DJW   - First version.
 *  14 Feb 95    RZ
 */

#include <sms.h>
#include <errno.h>
#include <signal.h>
#include <sys/signal.h>

int sigsuspend (smask)
  sigset_t *smask;
{
    /*
     *  Set new signal mask
     *  (except for those that cannot be blocked)
     */

    (void) sigprocmask(SIG_SETMASK,smask,NULL);

    /*
     *  Then suspend outselves.  We can then
     *  only get restarted by an outside agency.
     */

    (void) sms_ssjb ((jobid_t)-1, -1, NULL);

    /*
     *  If we resume, then we always
     *  return this error code.
     */
    return (EINTR);
}
