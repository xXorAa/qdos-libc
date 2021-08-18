#include <qdos.h>

/********************************************************
 * Routine to initialise the memory pool with all       *
 * remaining memory.                                    *
 ********************************************************/

int allmem()
{
    return bldmem(0);
}
