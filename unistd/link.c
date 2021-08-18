/*
 *      l i n k
 *
 *  Unix/Posix compatible call to link to a file.
 *
 *  As QDOS and SMS do not support the concept of links (i.e. multiple
 *  names for the same physical file), then this command is always failed
 *  indicating that no further links are allowed.
 *
 *  AMENDMENT HISTORY
 *  ~~~~~~~~~~~~~~~~~
 *  21 Aug 94   DJW   - First version
 */

#define __LIBRARY__

#include <unistd.h>
#include <errno.h>
#include <sys/stat.h>

int     link (const char *path1, const char * path2)
{
    struct stat buf[1];

    (void) path2;       /* Dummy to stop warning from compiler */

    if (_Stat(path1,buf) != 0) {
        return -1;
    }
    errno = EMLINK;
    return -1;
}

