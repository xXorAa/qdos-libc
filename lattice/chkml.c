#include <qdos.h>

/********************************************************
 * Routine to return the largest chunck of unallocated  *
 * memory in the level 2 pool.                          *
 ********************************************************/

unsigned long chkml()
{
    register struct MELT *p;
    register unsigned long maxsize = 0L;

    /* Search the entire memory list */
    for( p = _melt.mp_next; p; p = p->mp_next)
        if( (p->mp_size * MELTSIZE) > maxsize )
            maxsize = (p->mp_size * MELTSIZE); /* This block is bigger than current
                                                  maxsize, so replace maxsize */
    return maxsize;
}

