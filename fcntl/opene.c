/*
 *                o p e n e
 *
 *  Search more than just the default directory, 
 *  if parameter set ok.
 *
 *  Shares support routine _do_opene() with the
 *  fopene() library call.
 *
 *  Look at 9 bits in paths, top three first,
 *  followed by next 3, followed by bottom 3.
 *      If 3bits == 4 - search prog dir.
 *      If 3bits == 2 - search dest dir.
 *      If 3bits == 1 - search data dir.
 *      If 3bits == 0 - don't try and open file.
 *
 * AMENDMENT HISTORY
 * ~~~~~~~~~~~~~~~~~
 *  16 Oct 93   DJW   - Changed prototype for _do_opene() to remove compiler
 *                      warning message.
 */

#define __LIBRARY__

#include <qdos.h>
#include <fcntl.h>

#ifdef __STDC__
#define _P_(params) params
#else
#define _P_(params) ()
#endif

int opene   _LIB_F3_( const char *,   name, \
                      mode_t,   mode, \
                      int,      paths)
{
    return (int)_do_opene((char *)name, (long)mode, paths, 
                        (long (*)_P_((char *, long, ...)))_Open);
}

#undef _P_

