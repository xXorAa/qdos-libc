/*
 *  q l f p t o f _ c
 *
 *  Routine to convert a QLFLOAT to an 32-bit float.
 *  to stop promotion when float is smaller than double,
 *  the anwer is stored in a union and then returned as a long.
 */

#define __LIBRARY__

#include <qdos.h>

long    qlfp_to_f  _LIB_F1_ ( struct QLFLOAT *,  qlfp)
{
    union {
        float   f;
        long    l;
    } result;

    result.f = qlfp_to_d (qlfp);
    return result.l;
}

