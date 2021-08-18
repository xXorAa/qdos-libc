#
/*
 *      q l f p t o d _ x
 *
 *  Routine to convert a QL float to a double.
 *
 *  Handles both the Motorola Fast Floating Point Format
 *  and also the IEEE format.
 *
 *  Equivalent to c routine :-
 *      double qlfp_to_d( struct qlfloat *qlfp)
 *
 * AMENDMENT HISTORY
 * ~~~~~~~~~~~~~~~~~
 *   06 Nov 93   DJW   - Added underscore to entry point names
 */

#include <float.h>

    .text
    .even
    .globl _qlfp_to_d

#if IEEE_FLOAT
;------------------------------- IEEE -------------------------------------
;   routine to convert a QL floating point number to a IEEE double.

_qlfp_to_d:
    move.l  4(a7),a0        ; get pointer to qlfp
    movem.l d2-d3,-(a7)     ; save regs
    moveq   #0,d2           ; clear d2 for later use
    move.w  (a0)+,d2        ; qlfp exponent
    move.l  (a0),d0         ; qlfp mantissa
    bne     notzero         ; mantissa not zero
    cmp.w   #0,d2           ; exponent zero ?
    bne     notzero

; if we get here qlfp was zero, just return 0 in d0 and d1

    moveq   #0,d0
    moveq   #0,d1
    bra     finish

; qlfp is not zero
; now check if the qlfp is negative

notzero:
    moveq.l #0,d3           ; set sign bit as clear
    btst.l  #31,d0
    beq     positive

; qlfp number is negative - negate the mantissa
; and set the sign bit in the exponent

negative:
    bset    #31,d3          ; set sign bit
    neg.l   d0
    btst.l  #30,d0
    bne     positive
    addq.w  #1,d2           ; increase exponent value by 1
positive:
    sub.w   #$402,d2        ; set up the exponent
    lsl.w   #4,d2           ; move it up to the top
    swap    d2              ; put the exponent in the top word
    or.l    d3,d2           ; ... and add sign bit

; now shift the mantissa up by 2 - to get rid of the implied bit

    lsl.l   #2,d0

; put the bottom word in storage - we only really need the bottom 12
; bits.
    move.w  d0,d1
    moveq   #12,d3
    lsr.l   d3,d0

; shift up by 4 to get rid of the unwanted top 4 bits
; swap the words in the second part of the mantissa,

    lsl.w   #4,d1
    swap    d1

; or the exponent into d0 - the mantissa

    or.l    d2,d0

; d0 and d1 now contain the double ieee fp
; - return

finish:
    movem.l (a7)+,d2-d3
    rts

#else
;------------------------------ MFFP -----------------------------
;   routine to convert a QL floating point number to MOTOROLA FFP.

_qlfp_to_d:
    move.l  4(a7),a0        ; get pointer to qlfp
    move.w  (a0)+,d0        ; qlfp exponent (in bottom word)
    move.l  (a0),d1         ; qlfp mantissa
    tst.w   d0              ; is exponent zero ?
    bne     notzero
    tst.l   d1              ; is mantissa zero
    bne     notzero

; if we get here qlfp was zero, just return 0 in d0

    moveq   #0,d0
    rts

; qlfp is not zero

notzero:
    sub.w   #$7C0,d0        ; set up the exponent
    lsr.l   #4,d0           ; move it to bottom byte

; now check if the qlfp is negative

    btst.l  #31,d1
    beq     positive

; qlfp number is negative - negate the mantissa
; and set the sign bit in the exponent

negative:
    neg.l   d1
    bset    #7,d0

positive:
    andi.l  #$7FFFFF80,d1       ; mask out any bits of mantissa not needed
    lsl.l   #1,d1               ; move into position
    or.l    d1,d0               ; add matissa to final result
    rts

#endif

