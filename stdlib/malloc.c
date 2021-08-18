/*
 *              m a l l o c
 *
 * Routine to do a dynamic memory allocation.
 *
 */

#define __LIBRARY__

#include <assert.h>
#include <stdlib.h>
#include <unistd.h>
#include <qdos.h>

void *malloc _LIB_F1_(size_t,   size)
{
    char *ret;

    assert (stackcheck());
    if ( (size == 0L )
    ||   ((ret = (char *)lsbrk((long)(size += 4)))==NULL) ) {
        return NULL;
    }

    /* The first long word of the area contains the length allocated.
     * In this implementation it is set up within the 'lsbrk' routine
     * so we do not need to do it explicitly here.
     */
     /*    *(long *)ret = size;     */
     
    return (void *)(ret + 4);
}

