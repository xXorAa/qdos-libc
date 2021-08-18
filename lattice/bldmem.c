#include <qdos.h>

#define ONE_K_BLOCK (1024L / MELTSIZE )

/***********************************************
 * Routine to set up the memory pool variables.*
 * n is either the number of 1K blocks to add  *
 * to the memory pool, or if n = 0 all free    *
 * memory is added to the level 2 pool.        *
 ***********************************************/

int bldmem( n )
int n;
{
    extern char *lsbrk();
    register char *ret;

    _pool.mp_next = NULL;
    _pool.mp_size = 0;

    /* Now allocate the first memory block - to set up
       the _pool structure */
    if(!( ret = lsbrk( 1024L )))
        return -1;

    /* 1K was grabbed - this will be the base of our memory
       pool - set it in _pool.mp_next, and size is :-
       1k / sizeof( struct MELT ) */
    _pool.mp_next = (struct MELT *)ret;
    _pool.mp_size = ONE_K_BLOCK;

    /* Now allocate as many extra 1K blocks as asked for,
       or as many as there are, whichever is smaller */

    while( --n ) {
        if(!lsbrk( 1024L ))
            break;
        _pool.mp_size += ONE_K_BLOCK;
    }

    rstmem(); /* Set up _melt - free list */
    return 0;
}

