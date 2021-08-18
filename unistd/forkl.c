/*
 *          f o r k l
 *
 *  Unix comaptible routine to fork off another process.
 *  Only the PROG_USE directory is to be searched.
 *
 *  Returns the QDOS process id of the new process,
 *  or -1 on error.
 *
 *  Arguments passed as separate parameters.
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
#include <stdarg.h>

#undef forkl

pid_t forkl( const char * name, int * chans, const char * argvs, ...)
{
    return (pid_t)_forkexec( name, 2, chans, &argvs, (jobid_t) -1);
}

