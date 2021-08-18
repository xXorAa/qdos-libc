/*
 *  g e t c w d
 *
 * Routine to get the current data directory.
 */

#define __LIBRARY__

#include <qdos.h>

char _data_use[] = "DATA_USE";

char *getcwd( str, size )
char *str;
int size;
{
    return _getcd( _data_use, str, size);
}
