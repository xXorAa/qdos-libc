/*
 *          s i g p r i n t f
 *
 *  Routine that is only used when building the C68 signal handling
 *  support to include debugging options.
 *
 *  AMENDMENT HISTORY
 *  ~~~~~~~~~~~~~~~~~
 */
#include <signal.h>
#include <qdos.h>
#include <stdio.h>

#ifdef SIGDEBUG
chanid_t _sigdebugch;
extern _sigdebug;

int sigprintf(frmt, a1,a2,a3,a4,a5,a6,a7,a8,a9,a10,a11,a12,a13,a14)
char *frmt;
{  char buf[250];

   if(_sigdebug)
   {
    sprintf(buf,frmt,a1,a2,a3,a4,a5,a6,a7,a8,a9,a10,a11,a12,a13,a14);
    io_sstrg(_sigdebugch,-1,buf,strlen(buf));
   }
}
#endif  /* SIGDEBUG */

