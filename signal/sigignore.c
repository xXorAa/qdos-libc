/*
 *      s i g i g n o r e
 *
 *  Unix SVR4 routine to seta signal disposition to SIGN_IGNORE
 *
 *  AMENDMENT HISTORY
 *  ~~~~~~~~~~~~~~~~~
 *  24 Mar 94   DJW   - First version.
 *  14 Feb 95    RZ
 */

#define __LIBRARY__

#include <signal.h>

int sigignore (signo)
  int        signo;
{
    return ((signal (signo, SIG_IGN) == SIG_ERR) ? -1 : 0);
}
