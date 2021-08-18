#include <qdos.h>

/********************************************************
 * Routine to reset all memory allocations.             *
 ********************************************************/
/*
 *
 * Definition of memory pool and free blocks headers. They
 * are in this routine as it is called directly from the
 * standard C startup module
 *
 */
struct MELT _pool = { 0 }, _melt = { 0 };

void rbrk()
{
    extern long _msize;
    extern char *_mnext, *_mbase;

    _msize += (_mnext - _mbase); /* Reset total memory size */
    _mnext = _mbase; /* Reset heap memory base */

    /* Set _melt and _pool structures */
    _melt.mp_next = _pool.mp_next = NULL;
    _melt.mp_size = _pool.mp_size = 0L;
}
