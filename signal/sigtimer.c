/*
 *      s e t _ t i m e r _ e v e n t
 *
 *  Support routine used internally by Signal handlers.
 *  Can also be called directly by user code.
 *
 *  AMENDMENT HISTORY
 *  ~~~~~~~~~~~~~~~~~
 */

#include <signal.h>
#include <sys/signal.h>
#include <qdos.h>
#include <errno.h>


int set_timer_event(struct TMR_MSG *msg)
{
    struct REGS rgs;

    msg->magic = SIG_MAGIC;    /* '%MSG' */
    msg->len   = sizeof(struct TMR_MSG);
    msg->type  = M_TIMER;
    msg->prio  = _defsigsp;

    rgs.D0 = 4;                /* io.edlin */
    rgs.D1 = sizeof(struct TMR_MSG);
    rgs.D2 = sizeof(struct TMR_MSG);
    rgs.D3 = 10;
    rgs.A0 = (char *)_sigch;
    rgs.A1 = (char *)msg + msg->len;

    if (qdos3(&rgs,&rgs) != 0)
    {
        _oserr = rgs.D0;
        errno=EOSERR;
        return -1;
    }

    if (rgs.A1 == (char *)msg)
        return 0;
    else
        return msg->len;
}

