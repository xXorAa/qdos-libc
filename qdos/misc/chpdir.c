/*
 *         c h p d i r _ c
 *
 *  Call the change directory routine with the correct
 *  parameters.
 *
 */

#define __LIBRARY__

#include <qdos.h>

int chpdir  _LIB_F1_ ( char *, str)
{
    return _cd( _prog_use, str);
}
