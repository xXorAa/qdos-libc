/*
 *  k e y r o w
 *
 * Routine to read the QL keyboard directly, given a row
 *
 * AMENDMENT HISTORY
 * ~~~~~~~~~~~~~~~~~
 */

#define __LIBRARY__

#include <qdos.h>

static char params[] = { 9, 1, 0, 0, 0, 0, 0, 2 };

int keyrow _LIB_F1_( char,row )
{
    params[6] = row;
    return mt_ipcom( params );
}
