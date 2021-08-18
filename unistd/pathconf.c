/*
 *      p a t h c o n f
 *
 *  Posix compatible routine to get configuration details on a file.
 *
 *  AMENDMENT HISTORY
 *  ~~~~~~~~~~~~~~~~~
 *
 *  26 Jan 95   DJW   - Added 'const' keyword to parameter definitions
 */

#define __LIBRARY__

#include <unistd.h>
#include <limits.h>
#include <errno.h>
#include <qdos.h>

long  pathconf _LIB_F2_ (const char *,  path, \
                         int,           name)
{
    (void) path;        /* dummy to suppress compiler warning */
    (void) name;

    errno = EINVAL;
    return -1L;
}


