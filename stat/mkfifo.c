/*
 *      m k f i f o
 *
 *  POSIX compatible routine to make a fifo special file.
 *
 *  The QDOS implementation is limited to supporting names that
 *  start with the characters PIPE_  (case insignificant).  All
 *  other names will be rejected with an error code.
 *
 *  AMENDMENT HISTORY
 *  ~~~~~~~~~~~~~~~~~
 */

#define __LIBRARY__

#include <sys/types.h>
#include <sys/stat.h>
#include <errno.h>

int mkinfo (const char * path, mode_t mode)
{
    (void) path;        /* dummy to suppress compiler warning */
    (void) mode;

    errno = ENOSPC;
    return -1;
}

