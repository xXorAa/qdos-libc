/*
 *  g e t c p d
 *
 * Routine to get the current program directory.
 */

#define __LIBRARY__

#include <qdos.h>

char _prog_use[] = "PROG_USE";

char *getcpd _LIB_F2_ ( char *,  str,   \
                        int,     size)
{
    return _getcd( _prog_use, str, size);
}
