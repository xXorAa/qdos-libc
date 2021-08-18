/*
 *          c l o s e d i r
 *
 *  Close a directory (UNIX style)
 *
 *  As the other directory handling routines never really
 *  keep the directory open at the QDOS level, this
 *  merely means freeing the associated data structures.
 *
 * AMENDMENT HISTORY
 * ~~~~~~~~~~~~~~~~~
 *  21 Aug 93   DJW   - Added error checking.
 */

#include <dirent.h>
#include <errno.h>
#include <stdlib.h>

int closedir(dirp)
DIR *dirp;
{
    if (dirp == NULL) {
        errno = EBADF;
        return -1;
    }
    free(dirp);
    return 0;
}

