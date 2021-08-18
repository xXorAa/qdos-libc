#include  <signal.h>
#include <sys/signal.h>

int sigcleanup(void)
{
#ifdef SIGDEBUG
   sigprintf("calling sigcleanup\n");
#endif /* SIGDEBUG */
   return (*_sigvec)(_sigch,0);
}

