/*
 *              f o r k v
 *
 *  Unix comaptible routine to fork off another process.
 *  Only the PROG_USE directory is to be searched.
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

#define TRADITIONAL

#define __LIBRARY__

#include <unistd.h>
#include <qdos.h>

pid_t forkv( name, chans, argv)
  const char * name;
  int *  chans;
  char * const * argv;
{
    return (pid_t)_forkexec( name, 2, chans, argv, (jobid_t)-1);
}

