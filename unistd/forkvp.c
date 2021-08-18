/*
 *                  f o r k v p
 *
 *  Unix comaptible routine to fork off another process.
 *  The PROG_USE and DATA_USE directories are to be searched.
 *
 *  Returns the QDOS process id of the new process,
 *  or -1 on error.
 *
 *  Parameters passed as an array
 *
 *  AMENDMENT HISTORY
 *  ~~~~~~~~~~~~~~~~~
 *  28 Aug 94   DJW   - Amended to work with _forkexec() routine instead of
 *                      previous _fex() routine which changes last parameter.
 */

#define __LIBRARY__

#include <unistd.h>
#include <qdos.h>

pid_t forkvp( const char * name, int * chans, char * const * argv)
{
    return (pid_t)_forkexec( name, 3, chans, argv, (jobid_t)-1);
}

