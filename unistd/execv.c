/*
 *              e x e c v
 *
 * Routine to start off another process. Waits for it to
 * finish and returns its QDOS error code. _oserr == 0 if
 * error code is from new process, else process didn't
 * start.
 *
 *  AMENDMENT HISTORY
 *  ~~~~~~~~~~~~~~~~~
 *  28 Aug 94   DJW   - Amended to work with _forkexec() routine instead of
 *                      previous _fex() routine which changes last parameter.
 *
 *  26 Jan 95   DJW   - Added 'const' keyword to parameter definitions
 */

#define __LIBRARY__

#include <unistd.h>
#include <qdos.h>

int execv   _LIB_F3_ ( const char *,    name, \
                       int  *,          chans, \
                       char * const *,  argv)
{
    /*
     *  Fork off another process, searching directory
     *  _pdir_ only, and returning the new job exit code
     */
    return (int)_forkexec( name, 2, (int *)chans, argv, (jobid_t)0);
}

