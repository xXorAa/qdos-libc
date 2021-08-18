#include <qdos.h>

/********************************************************
 * Routine to reset the level 2 memory pool to its      *
 * initial state (as before any allocations) after using*
 * bldmem or allmem.                                    *
 ********************************************************/

int rstmem()
{
    _melt.mp_next = _pool.mp_next;
    _melt.mp_size = _pool.mp_size;
    if( !_pool.mp_size )
        return -1; /* No memory pool to reset ! */

    _melt.mp_next->mp_next = NULL;
    _melt.mp_next->mp_size = _melt.mp_size;

    return 0;
}
