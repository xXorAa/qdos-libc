/*
 *      _ g e t c d
 *
 * Routine to get the current destination directory.
 */

#define __LIBRARY__

#include <qdos.h>

char _spl_use[] = "SPL_USE";

char *getcdd  _LIB_F2_ ( char *, str,
                         int,    size)
{
    return _getcd( _spl_use, str, size);
}
