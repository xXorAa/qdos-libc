/*
 *      _ S i g N o I m p
 *
 *  Routine called if signal support not loaded
 *  and it is needed by this program.
 *
 *  The user can provide more sophisticated versions of
 *  this routine if more complex behaviour is wanted
 *  that is defined here.
 *
 *  AMENDMENT HISTORY
 *  ~~~~~~~~~~~~~~~~~
 *  24 Oct 95   DJW   - Alteration so that the message is only output
 *                      once during the running of a program.
 *
 *  02 Jan 96   DJW   - Enhanced to support __SigNoCnt variable
 */

#include <signal.h>
#include <sys/signal.h>
#include <string.h>

#define __LIBRARY__
#include <qdos.h>

int _SigNoImp(int x,...)
{
    (void) x;   /* Dummy to keep compiler happy */

    if (__SigNoCnt != 0 && __SigNoMsg != NULL)
    {
        (void) io_sstrg(_endchanid, -1, __SigNoMsg, (short)strlen(__SigNoMsg));
        __SigNoCnt--;
    }
    return (-1);
}

