;
;   l _ t o _ q l f p
;
; AMENDMENT HISTORY
; ~~~~~~~~~~~~~~~~~
;
;   06 Nov 93   DJW   - Added underscore to entry point names

    .text
    .even
    .globl _l_to_qlfp

; routine to quickly convert a 32 bit signed integer into a qlfloat
; corresponds to the c routine :-
; qlfloat *l_to_qlfp( qlfloat *qlf, int i)

_l_to_qlfp:
    move.l  4(a7),a0        ; save qlfloat pointer
    move.l  8(a7),d0        ; int i
    movem.l d2-d4,-(a7)     ; save register variables
    moveq.l #0,d2           ; sign value
    move.l  d2,d3           ; shift value
    tst.l   d0              ; zero or -ve ?
    beq     zeroval         ; zero
    bpl     plusval         ; +ve

; i is negative here. set the sign value then make i positive

    moveq   #1,d2           ; boolean to say -ve
    not.l   d0              ; i has all bits reversed
    bne     plusval         ; i was not -1, so can continue

; i was -1, so cannot go into following loop, as it now is zero

    moveq   #0,d2           ; pretend i was positive
    move.l  #$80000000,d1   ; set d1 correctly
    move.w  #31,d3          ; shift value
    bra     outloop         ; continue

plusval:
    move.l  d0,d1           ; save a copy of the original i

; check for shortcuts with shifts

    and.l   #$ffffff00,d0   ; shift by 23 ?
    bne     bigger23        ; no cheat available
    move.w  #23,d3          ; shift value is 23
    lsl.l   d3,d1           ; shift copy of i
    bra     nbigger         ; continue

; check for 15 bit shortcut shift

bigger23:
    move.l  d1,d0           ; restore i
    and.l   #$ffff0000,d0   ; shift by 15 ?
    bne     nbigger         ; no cheat available
    move.w  #15,d3          ; shift value is 15
    lsl.l   d3,d1           ; shift copy of i

; no shortcuts available

nbigger:
    move.l  d1,d0           ; restore i
    and.l   #$40000000,d0   ; if(!(i & 0x40000000))
    bne     outloop         ; bit is set, no more shifts
    lsl.l   #1,d1           ; shift copy of i
    addq.l  #1,d3           ; increment shift count
    bra     nbigger         ; ensures i is restored

; finished shifts - copy into qlfloat
; correct shifted i is in d1, d0 contains i & 0x40000000

outloop:
    move.w  #$81f,d4
    sub.w   d3,d4           ; set exponent correctly
    move.w  d4,(a0)+        ; copy into exponent

; difference here between positive and negative numbers
; negative should just be shifted until first zero, so as we
; have 2s complemented and shifted until first one, we must now
; re-complement what is left

    tst.b	d2
    beq     setmant         ; positive value here - just copy it

; negative value, xor it with -1 shifted by same amount as in shift (d3)
; to convert it back to -ve representation

    moveq.l #-1,d2          ; set d2 to all $FFs
    lsl.l   d3,d2           ; shift it by shift (d3 )
    eor.l   d2,d1           ; not the value by xoring

; negative value restored by above

setmant:
    move.l  d1,(a0)         ; copy into mantissa
fin:
    movem.l (a7)+,d2-d4     ; reset register variables
    move.l  4(a7),d0        ; correct return value
    rts

; quick exit if zero

zeroval:
    move.w  d2,(a0)+        ; zero exponent
    move.l  d2,(a0)         ; zero mantissa
    bra     fin

