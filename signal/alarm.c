/*
 *      a l a r m
 *
 *  Unix and Posix compatible routine to send a SIGALARM signal to the
 *  calling process after the specified number of seconds.  It can
 *  also be used to cancel any outstanding alarm signals if the
 *  number of seconds is specified as zero.  Alarms are not stacked,
 *  suscessive calls reset the alarm clock of the calling process.
 *
 *  Returns:
 *      0   No outstanding request
 *      +ve Number of seconds outstanding in previous request
 *
 *  Notes:
 *      1)  The SIGALARM may be delayed by other system activity
 *      2)  The default action for SIGALARM is to terminate the process.
 *
 *  AMENDMENT HISTORY
 *  ~~~~~~~~~~~~~~~~~
 *  31 Jan 94   DJW   - First Version
 *
 *  25  Feb 95  RZ    - Complete rewrite
 */


#include <signal.h>
#include <sys/signal.h>
#include <unistd.h>
#include <qdos.h>
#include <errno.h>

int   alarm (unsigned int  w)
{
    struct TMR_MSG msg;
    int r;

    msg.txi     = MT_SECS;
    msg.signr   = SIGALRM;
    msg.jobid   = -1L;
    msg.uval    = 0;
    msg.t_evid  = EV_ALARM;
    msg.t_ticks = w;
    msg.t_int   = 0;

    if (w==0) 
    {
        msg.signr=0;            /* cancel */
    }

    r = set_timer_event(&msg);

    if (r<0) 
    {
        _oserr=r; 
        errno=EOSERR;
        return (int)SIG_ERR;
    }
    return (r ? msg.t_ticks : 0);
}

