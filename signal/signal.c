/*
 *          s i g n a l 
 *
 *  AMENDMENT HISTORY
 *  ~~~~~~~~~~~~~~~~~
 *  03 Apr 94   DJW   - Separated some code off into support routime.
 *
 *  25 Feb 95   RZ    - Complete rewrite
 */

#include <signal.h>
#include <sys/signal.h>
#include <errno.h>


void (* signal(int signr,void (*action) (int)) )(int)
{
  struct sigaction act;
  struct sigaction oact;

  act.sa_handler = action;
  act.sa_flags = 0;
  act.sa_mask = 0;

  return (sigaction(signr,&act,&oact) < 0) ? SIG_ERR : oact.sa_handler;
}

