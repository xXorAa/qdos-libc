/*
 *      u m a s k
 *
 *  Emulates the Unix/POSIX umask() system call.
 *
 *  In practise because QDOS does not support the concept of file
 *  access permissions in the Unix/Posix sense this call is really
 *  a dummy as the creation mask will have no affect on file
 *  creation.
 *
 *  AMENDMENT HISTORY
 *  ~~~~~~~~~~~~~~~~~
 *  20 Aug 94   DJW   - First version
 */

#include <sys/types.h>
#include <sys/stat.h>

mode_t  _umaskcur = S_IRUSR | S_IWUSR | S_IRGRP | S_IWGRP | S_IROTH | S_IWOTH;

mode_t  umask (cmask)
  mode_t cmask;
{
    mode_t  oldval;

    oldval = _umaskcur;
    _umaskcur = cmask;
    return (oldval);
}

