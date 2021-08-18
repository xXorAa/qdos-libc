/*
 *         c h d d i r _ c
 *
 *  Call the change directory routine with the correct
 *  parameters.
 *
 */

#define __LIBRARY__

#include <qdos.h>

int  chddir _LIB_F1_ ( char *,  str)
{
    return _cd( _spl_use, str);
}
