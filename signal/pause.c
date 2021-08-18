/*
 *      p a u s e
 *
 *  Unix and Posix compatible routine to suspend the calling
 *  process until the delivery of a signal whose action is either
 *  to execute a signal catching action or terminate the process.
 *
 *  Alwaysreturns EINTR
 *
 *  AMENDMENT HISTORY
 *  ~~~~~~~~~~~~~~~~~
 *  31 Jan 94   DJW   - First Version
 */

#define __LIBRARY__
#define _LIBRARY_SOURCE

#include <unistd.h>
#include <qdos.h>
#include <errno.h>

int   pause _LIB_F0_ (void)
{
    (void) mt_susjb(-1, -1, NULL);
    return EINTR;
}

