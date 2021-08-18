/*
 *      c h o w n
 *
 *  Unix/Posix call to change a files owner and/or group.
 *
 *  As QDOS and SMS do not really support the idea of owners
 *  and groups for files, this call will always suceed as long
 *  as the file exists.
 *
 *  AMENDMENT HISTORY
 *  ~~~~~~~~~~~~~~~~~
 *  21 Aug 94   DJW   - First version
 */

#define __LIBRARY__

#include <unistd.h>
#include <sys/types.h>
#include <sys/stat.h>

int     chown   (const char * path, uid_t owner, gid_t group)
{
    struct stat buf[1];

    if (_Stat(path, buf) != 0) {
        return -1;
    }
    
    (void) owner;   /* dummies to stop the compiler giving warnings */
    (void) group;   /* about variables not being used. */

    return 0;
}

