#
/*
 *       s t a c k c h e c k
 *
 *  This file is used to check that the stack has not overflowed the
 *   area allocated for it.
 *
 *   Equivalent to C routine:
 *
 *      long stackcheck (void)
 *
 *   The return values are:
 *          0       Check failed
 *          +ve     Current margin
 *
 * AMENDMENT HISTORY
 * ~~~~~~~~~~~~~~~~~
 *  18 Nov 93   DJW   - Rewrote in assembler
 */

#if 0
/*
 *  C version
 */
#include "libc.h"
#include <qdos.h>

extern  long    _spbase, sptop;

long   stackcheck()
{
    long    value;

    value = stackreport();
    return ((value < _stackmargin) ? 0 : value);
}
#else

/*
 *  Assembler version
 */
    .text
    .globl _stackcheck

_stackcheck:
    move.l  a7,d0               ; get stack pointer value
    sub.l   __SPbase,d0         ; ... less base to get current margin
    cmp.l   __stackmargin,d0    ; less than margin we must allow ?
    bpl     fin                 ; ... NO, then return current value
    moveq   #0,d0               ; ... YES, then set error reply
fin:
    rts

#endif

