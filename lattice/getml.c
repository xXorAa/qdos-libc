/*
 *          g e t m l
 *
 * Lattice routine to allocate a chunk of memory
 * from the memory pool.
 *
 * This is only retained for compatibility as all
 * the work is now done in the lsbrk routine.
 */

#define __LIBRARY__

#include <stdlib.h>
#include <unistd.h>

char * getml _LIB_F1_( long, lnbytes)
{
    return (lsbrk(lnbytes));
}

