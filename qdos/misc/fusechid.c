/*
 *                  f u s e c h i d
 *
 *  This routine is used to set up a level 2 File Pointer, and
 *  a level 1 file descriptor for a file that has been opened 
 *  at Level 0 (i.e. QDOS)
 *
 *  AMENDMENT HISTORY
 *  ~~~~~~~~~~~~~~~~~
 *  02 Sep 93   DJW   - Changed to use fdopen() routine for creating level
 *                      2 pointer as this does not depend on internal
 *                      structure of STDIO library.
 */

#define __LIBRARY__

#include <qdos.h>
#include <stdio.h>

FILE * fusechid _LIB_F1_ ( chanid_t,   chanid)
{
    int fd;

    if ((fd = usechid(chanid)) < 0) {
        return NULL;
    }
    return fdopen(fd, "r+");
}

