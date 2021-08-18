/*
 *      s e n d s i g . c
 */
#include <signal.h>
#include <sys/signal.h>
#include <qdos.h>


int sendsig(chanid_t ch,jobid_t job,
            long signr, struct SIG_PRIOR_S pri,long uval)
{
  struct SIG_MSG msg;
  int r;
  msg.magic = SIG_MAGIC;                /* '%MSG' */
  msg.len   = sizeof(struct SIG_MSG);
  msg.jobid = job;
  msg.signr = signr;
  msg.type  = M_SIG;
  msg.txi   = 0;
  msg.prio  = pri;
  msg.uval  = uval;

  r = io_sstrg(ch,10,&msg,sizeof(struct SIG_MSG));

  return (r<0 ? r : 0);
}

