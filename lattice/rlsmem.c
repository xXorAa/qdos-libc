/*
 *          r l s m e m
 *
 * LATTICE comaptible routine to release an 'int' number 
 * of bytes back to  the memory pool.
 */

#define __LIBRARY__

#include <stdlib.h>

int rlsmem _LIB_F2_( char *,    p,       \
                     int,       nbytes)
{
    return rlsml( p, (long)nbytes );
}
