/*
 *      s i z m e m
 *
 * Lattice compatible routine to return the number of 
 * unallocated bytes in the memory pool.
 */

#define __LIBRARY__

#include <qdos.h>

int sizmem _LIB_F0_(void)
{
    extern long _mfree;

    return (_mfree);
}
