/*
 *      p s i g n a l
 */

#define __LIBRARY__

#include <signal.h>
#include <string.h>
#include <stdio.h>
#include <stdlib.h>

static char * siglist[_NSIG] = {
/* SIGHUP     1 */ "hangup",
/* SIGINT     2 */ "terminal interrupt (DEL)",
/* SIGQUIT    3 */ "quit (ASCII FS)",
/* SIGILL     4 */ "illegal instruction",
/* SIGPIPE    5 */ "write on a pipe with no one to read it",
/* SIGSEGV    6 */ "segement violation / illegal address",
/* SIGBUS     7 */ "misaligned",
/* SIGFPE     8 */ "floating point exception",
/* SIGKILL    9 */ "kill (cannot be caught or ignored)",
/* SIGALRM   10 */ "alarm clock",
/* SIGABRT   11 */ "IOT instruction",
/* SIGTRACE  12 */ "trace signal",
/* SIGWINCHD 13 */ "window definition changed",
/* SIGWMREQ  14 */ "wman callback",
/* SIGTERM   15 */ "software termination signal from kill",
/* SIGUSR1   16 */ "user defined signal # 1 ",
/* SIGUSR2   17 */ "user defined signal # 2 "
    };

void psignal _LIB_F2_ (int,           signo,     \
                       const char *,  s)
{
#define MAXDIGS 11  /* maximum digits in unknown */
  static char unknown[] = {'U','n','k','n','o','w','n',' ',
                   's','i','g','n','a','l',' ',
                   '0','0','0','0','0','0','0','0','0','0','0',0};

  char * sigdesc;

  (void) fflush (stderr);

    if (s != NULL && *s != 0) 
    {
        (void) fwrite((char *) s, strlen(s),1,stderr);
        (void) fwrite(": ", 2,1,stderr);
    }
    if (signo > 0 && signo <= _NSIG)
    {
        sigdesc = siglist[signo];
    }
    else 
    {
        (void) itoa(signo, &unknown[sizeof(unknown)-MAXDIGS-1]);
        sigdesc = &unknown[0];
    }
    (void) fwrite(sigdesc, strlen(sigdesc),1,stderr);
    (void) fwrite("\n", 1,1,stderr);
    (void) fflush (stderr);
}

void psiginfo _LIB_F2_(siginfo_t *,   pinfo,  \
                       const char *,  s)
{
    psignal (pinfo->si_signo,s);
    return;
}
