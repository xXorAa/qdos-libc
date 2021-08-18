/*
 *              f o p e n e
 *
 *  This is a routine to open a Level 2 file
 *  using QDOS search paths.
 *
 *             CAUTION
 *             ~~~~~~~
 *  It uses a support routine that is common to
 *  the opene() Level 1 call, and exploits the
 *  fact that sizeof(long) == sizeof(int) sizeof (char *)
 *
 * AMEMDMEMT HISTORY
 * ~~~~~~~~~~~~~~~~~
 *  16 Oct 93   DJW   - Allowed for fact that on error path, the do_opene()
 *                      routine can return -1.
 *                      (problem reported by David Gillam)W
 *
 *  25 Jan 95   DJW   - Added 'const' keyword to parameter definitions
 */


#define __LIBRARY__

#include <fcntl.h>
#include <stdio.h>

#ifdef __STDC__
#define _P_(params) params
#else
#define _P_(params) ()
#endif

FILE *fopene( name, str, which)
  const char * name;
  const char * str;
  int    which;
{
    long    reply;

    reply = _do_opene((char *)name, (long)str, which,
                             (long (*)_P_((char *, long, ...)))fopen);
    if (reply == -1L) {
        reply = 0L;
    }
    return (FILE *)reply;
}

#undef _P_

