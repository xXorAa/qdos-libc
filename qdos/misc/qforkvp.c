/*
 *                  q f o r k v p
 *
 *  QDOS specific routine to fork off another process specifying owner.
 *  The PROG_USE and DATA_USE directories are to be searched.
 *
 *  Returns the QDOS process id of the new process,
 *  or -1 on error.
 *
 *  Parameters passed as an array
 *
 *  AMENDMENT HISTORY
 *  ~~~~~~~~~~~~~~~~~
 *  28 Aug 94   DJW   - First version (based on forkvp() routine)
 *
 *  24 Jan 95   DJW   - Missing 'const' keyword added to function definition.
 */

#define __LIBRARY__

#include <qdos.h>

pid_t qforkvp  _LIB_F4_ ( const jobid_t,    owner, \
                          const char *,     name, \
                          int *,            chans, \
                          char * const *,   argv)
{
    return (pid_t)_forkexec( name, 3, chans, argv, owner);
}

