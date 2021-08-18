/*
 *          k b h i t
 *
 *  Lattice compatible routine to test if a key is
 *  avaialble from the onsole channel for getch() or
 *  getche() routines.
 */

#define __LIBRARY__

#include <qdos.h>
#include <stdio.h>

int kbhit  _LIB_F0_(void)
{
    return (!io_pend( _conchan, (timeout_t)0));
}
