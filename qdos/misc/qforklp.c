/*
 *              q f o r k l p
 *
 *  QDOS specific routine to fork off another process specifying owner.
 *  PROG_USE and then DATA_USE directories are to be searched.
 *
 *  Returns the QDOS process id of the new process,
 *  or -1 on error.
 *
 *  Arguements passed as separate parameters.
 *
 *  AMENDMENT HISTORY
 *  ~~~~~~~~~~~~~~~~~
 *  28 Aug 94   DJW   - First version (based on forkvp() routine)
 *
 *  24 Jan 95   DJW   - Missing 'const' keyword added to function definition.
 */

#define __LIBRARY__

#include <qdos.h>

pid_t qforklp   _LIB_F5_ (  const jobid_t, owner, \
                            const char *,  name, \
                            int *,         chans, \
                            const char *,  argvs, \
                            ..., )
{
    return (pid_t)_forkexec( name, 3, chans, &argvs, owner);
}

