/*
 *          l q s o r t _ c
 *
 *  Lattice compatible routine to sort an array of 
 *  long integer numbers into ascending sequence.
 *
 *  AMENDMENT HISTORY
 *  ~~~~~~~~~~~~~~~~~
 *  21 Apr 94   DJW   - Changed parameters to internal compare macro to use
 *                      pointer parameters.
 */

#define __LIBRARY__

#include <stdlib.h>
#include <qdos.h>

/*
 *  Internal routine to compare to long integer numbers
 */
static
int     _cmplong _LIB_F2_( const long *,   number1, \
                           const long *,   number2)
{
    if (*number1 < *number2) 
    {
        return (-1);
    }
    return (*number1 > *number2);
}


void    lqsort _LIB_F2_(long, array[], \
                        int,  count)
{
    qsort (array, count, sizeof(long), (int (*)(const void *, const void *))_cmplong);
    return;
}

