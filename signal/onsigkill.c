/*
 *      _ o n s i g k i l l
 *
 *  default action in case of SIGKILL
 */

#include <signal.h>
#include <sys/signal.h>
#include <qdos.h>
#include <errno.h>

void _onsigkill(int x)
{
  (void)x;
#ifdef DEBUG
  sigprintf("\n\n*** SIGKILL ***\n");
#endif
  (void) mt_frjob(-1,EINTR);
}

