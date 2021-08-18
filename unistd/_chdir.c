/*
 *      c h d i r
 *
 * Call the change directory routine with the correct
 * parameters.
 *
 * AMENDMENT HISTORY
 * ~~~~~~~~~~~~~~~~~
 */

#define __LIBRARY__

#include <unistd.h>
#include <qdos.h>

extern char _data_use[];

int chdir _LIB_F1_(char *,  str)
{
    return _cd( _data_use, str);
}

