/*
 *      l s t a t
 *
 *  This is the UNIX compatible routine to get information about a link
 *  rather than the file itself.  Since under QDOS, links are not
 *  supported this is the same as the stat() routine, so it is simply
 *  a call to that routine.
 *
 *  AMENDMENT HISTORY
 *  ~~~~~~~~~~~~~~~~~
 *  23 Dec 93   DJW   - First version.  Added simply for completeness to the
 *                      C68 library as I expect it to be very rarely used.
 *
 *  26 Jan 95   DJW   - Added 'const' keyword to parameter defintions.
 */

#define __LIBRARY__

#include <sys/stat.h>

int lstat (name, stbuf)
    const char  * name;
    struct stat * stbuf;
{
    return _Stat(name,stbuf);
}

