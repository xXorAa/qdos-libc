 /*
 *              f o r k l p
 *
 *  Unix comaptible routine to fork off another process.
 *  PROG_USE and then DATA_USE directories are to be searched.
 *
 *  Returns the QDOS process id of the new process,
 *  or -1 on error.
 *
 *  Arguements passed as separate parameters.
 *
 *  AMENDMENT HISTORY
 *  ~~~~~~~~~~~~~~~~~
 *  28 Aug 94   DJW   - Amended to work with _forkexec() routine instead of
 *                      previous _fex() routine which changes last parameter.
 */

#define TRADITIONAL

#define __LIBRARY__

#include <unistd.h>
#include <qdos.h>

#undef forklp

pid_t forklp( const char * name, int * chans, const char * argvs, ...)
{
    return (pid_t)_forkexec( name, 3, chans, &argvs, -1);
}

