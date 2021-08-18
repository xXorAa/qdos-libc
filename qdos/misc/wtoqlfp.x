/*
 *  Routine to use the QL's own ROM based word to QLFLOAT
 *  convert routine.
 *
 *  Equivalent to C call :
 *      QLFLOAT *w_to_qlfp( QLFLOAT *qlfp, WORD i);
 *
 *  AMENDMENT HISTORY
 *  ~~~~~~~~~~~~~~~~~
 *  06 Nov 93   DJW   - Added underscore to entry point names
 */

    .text
    .even
    .globl  _w_to_qlfp

_w_to_qlfp:
    movem.l d7/a6,-(a7)
    moveq.l #0,d7               ; Zero d7
    move.l  d7,a6               ; Zero a6 for call
    move.l  $C(a7),a1           ; Get area for RI stack
    add.l   #4,a1               ; Get a1 to point to word offset in structure
    move.w  $12(a7),(a1)        ; Set word on stack
    moveq.l #8,d0               ; Set up call parameter
    move.w  $11C,a0
    jsr     (a0)
    move.l  a1,d0               ; Set return address
    movem.l (a7)+,d7/a6
    rts

