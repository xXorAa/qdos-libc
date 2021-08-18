/*
 *              e x e c l
 *
 * Routine to fork off another process. Waits for it to
 * finish and returns its error code. _oserr == 0 if
 * code is returned from new job, _oserr != 0 means job
 * failed to start.
 *
 * Arguments passed as separate parameters.
 *
 *  AMENDMENT HISTORY
 *  ~~~~~~~~~~~~~~~~~
 *  28 Aug 94   DJW   - Amended to work with _forkexec() routine instead of
 *                      previous _fex() routine which changes last parameter.
 */

#define __LIBRARY__

#include <unistd.h>
#include <qdos.h>

int execl( const char * name, int * chans, const char * argvs, ...)
{
    /*
     *  Fork off another process, searching directory 
     *  _pdir_ only, and returning the new job exit code
     */
    return (int)_forkexec( name, 2, chans, &argvs, (jobid_t)0);
}

