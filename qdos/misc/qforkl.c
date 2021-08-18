/*
 *          q f o r k l
 *
 *  QDOS specific routine to fork off another process specifying.
 *  Only the PROG_USE directory is to be searched.
 *
 *  Returns the QDOS process id of the new process,
 *  or -1 on error.
 *
 *  Arguments passed as separate parameters.
 *
 *  AMENDMENT HISTORY
 *  ~~~~~~~~~~~~~~~~~
 *  28 Aug 94   DJW   - First version (based on forkvp() routine)
 *
 *  24 Jan 95   DJW   - Missing 'const' keyword added to function definition.
 */

#define __LIBRARY__


#include <unistd.h>
#include <qdos.h>
#include <stdarg.h>

pid_t qforkl _LIB_F5_ ( const jobid_t,  owner, 
                        const char *,   name, \
                        int *,          chans, \
                        const char *,   argvs, \
                        ..., )
{
    return (pid_t)_forkexec( name, 2, chans, &argvs, owner);
}

