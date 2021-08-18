/*
 *          k i l l / k i l l u
 *
 *  Routine to emulate UNIX kill() system call for sending
 *  signals to processes.
 *
 *  QDOS does not support the concept of user-id's and group-id's,
 *  so this routine effectively acts as if everyone is super-user
 *  in UNIX terms.
 *
 * AMENDMENT HISTORY
 * ~~~~~~~~~~~~~~~~~
 *  24 Jan 94   DJW  - First version that is more than a dummy.
 *
 *  25 Feb 95   RZ   - Complete rewrite
 */

#include <sys/types.h>
#include <signal.h>
#include <sys/signal.h>
#include <string.h>
#include <errno.h>
#include <unistd.h>
#include <qdos.h>

int killu (pid_t j, int i, int uval)
{

#ifdef SIGDEBUG
sigprintf("calling kill %d\t%d\n",j,i);
#endif

    if ( i==SIGKILL  /* || i==SIGSTOP */) 
    {
        return (sendsig(_sigch,j,i,_defsigskp,0) < 0) ? mt_frjob(j,EINTR) : 0;
    }
    _oserr=sendsig(_sigch,j,i,_defsigsp,uval);
    if (!_oserr) 
    {
        return 0;
    }
    errno = EOSERR;
    return -1;
}

int kill(pid_t j,int i)
{
    return killu (j,i,0);
}

#if 0
int sendsig (chanid_t ch,
             jobid_t  jobid,
             long     intrnr,
             struct SIG_PRIOR_S pri,
             long     usrval)
{
    struct REGS rgs;

    rgs.D0 = 0x2f;          /* non-standard use of sd_donl() */
    rgs.D1 = jobid;
    rgs.D2 = intrnr;
    rgs.D3 = 20;
    rgs.A0 = ch;
    rgs.A1 = *((long *)&pri);
    rgs.A2 = usrval;
    checksig();
    return qdos3(&rgs,&rgs);
}
#endif

