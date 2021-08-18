/*
 *              s b r k _ c
 *
 * Routine to update memory break pointer.
 *
 */

#include <unistd.h>

void * sbrk( nbytes )
int nbytes;
{
    void *ret;

    if(!(ret = lsbrk( (long)nbytes )))
        return (void *)-1;
    return ret;
}
