#
/*
 *      d t o q l f p _ x
 *
 *  Routine to convert a double to a QL float.
 *
 *  Handles both the Motorola Fast Floating Point Format
 *  and also the IEEE format.
 *
 *  Equivalent to C routine :-
 *     QLFLOAT_t *d_to_qlfp( QLFLOAT_t *qlf, double val)
 *
 *  AMENDMENT HISTORY
 *  ~~~~~~~~~~~~~~~~~
 *  06 Nov 93   DJW   - Added underscore to entry point names
 *
 *  03 Sep 94   DJW   - Added underscore to name as part of implementing
 *                      name hiding within the C68 libraries.
 *
 *  14 Sep 95   SNG   - Speed optimisations.
 *                      Bug fixed in FFP->QLFLOAT_t return pointer.
 *
 *  15 Sep 95   SNG   - More speed-ups including some fiendish register re-use.
 *
 *  06 Dec 95   DJW   - Corrected bug in code for checking for sign
 *                      (the wrong byte on the stack was being tested).
 *                      Problem report from Richar Zidlicky.
 *
 * KNOWN (LITTLE) BUGS
 * ~~~~~~~~~~~~~~~~~~~
 *
 * IEEE -> Qdos coercion does not round for first discarded bit.
 *
 * Denormalised IEEE value gives denormalised Qdos float, always
 * <1E-313 but with an exponent >0 (normally always normalised).
 */

#include <float.h>

    .text
    .even
    .globl __d_to_qlfp

__d_to_qlfp:

#if IEEE_FLOAT
;----------------------------- IEEEE -----------------------------------
; routine to convert IEEE double precision (8 byte) floating point
; to a QLFLOAT_t.

    move.l  4(a7),a0        ; pointer to qlfloat
    move.l  8(a7),d0        ; high long of IEEE double

; SNG - avoid loading low part for now so we can treat D1 as temporary

    add.l   d0,d0           ; Put sign bit in carry
    lsr.l   #1,d0           ; put zero where sign was
    bne     notzero         ; not zero
    move.l  12(a7),d1       ; Test low bits too (probably zero!)
    bne     notzero

; here the double was a signed zero - set the QLFLOAT_t and return

    move.w  d1,(a0)+        ; We know that D1 is 0 at this point
    bra     positive

; was not zero - do manipulations

notzero:
    move.l  d0,d1       ; set non-signed high part copy
;                         We are going to lose least significant byte so we
;                         can afford to over-write it.  We can thus take
;                         advantage that the shift size when specified in
;                         a register is modulo 64
    move.b  #20,d0      ; shift amount for exponent
    lsr.l   d0,d0       ; get exponent - tricky but it works!
    add.w   #$402,d0    ; adjust to QLFLOAT_t exponent
    move.w  d0,(a0)+    ; set QLFLOAT_t exponent

; now deal with mantissa
    
    and.l   #$fffff,d1  ; get top 20 mantissa bits
    or.l    #$100000,d1 ; add implied bit
    moveq   #10,d0      ; shift amount ;; save another 2 code bytes
    lsl.l   d0,d1       ; shift top 21 bits into place
;
;   SNG -This test was a nice idea but does not skip enough to be worthwhile
;
;   tst.l   d1          ; worth bothering with low bits ?
;   beq     lowzer      ; no
;   move.w  #22,d0      ; amount to shift down low long

    move.l  12(a7),d0   ; get less significant bits

;                         We are going to lose least significant byte so we
;                         can afford to over-write it.  We can thus take
;                         advantage that the shift size when specified in
;                         a register is modulo 64
    move.b  #22,d0      ; amount to shift down low long: not MOVEQ!
    lsr.l   d0,d0       ; position low 10 bits of mantissa
    or.l    d0,d1       ; D1 now positive mantissa

lowzer:
    tst.b   8(a7)       ; Top byte of IEEE argument
    bpl     positive    ; No need to negate if positive
    neg.l   d1          ; Mantissa in D1 now
positive:
    move.l  d1,(a0)     ; put mantissa in QLFLOAT_t
    subq.l  #2,a0       ; correct for return address
    move.l  a0,d0       ; set return value as original QLFLOAT_t address
    rts

#else
;------------------------------ MFFP --------------------------------
; routine to convert MOTOROLA Fast Float (4 byte) floating point 
; to a qlfloat.

    move.l  4(a7),a0        ; pointer to qlfloat
    move.l  8(a7),d0        ; MFFP float
    andi.l  #$FFFFFF7F,d0   ; put zero where sign was
    bne     notzero         ; not zero

; here the double was a signed zero - set the qlfloat and return

    clr.w   (a0)            ; clear exponent
    bra     positive

; was not zero - do manipulations

notzero:
    moveq.l #$7F,d1         ; quick fetch
    and.l   d0,d1           ; copy what we want
    add.w   #$7C0,d1        ; adjust to qlfloat exponent
    move.w  d1,(a0)         ; set qlfloat exponent

; now deal with mantissa

    lsr.l   #8,d0           ; isolate out exponent
    lsl.l   #7,d0           ; ... and shift to position
    tst.b   11(a7)          ;; test sign bit
    bpl     positive        ;; simple case
    
    neg.l   d0              ; negate mantissa
    moveq   #30,d1          ; 
    btst    d1,d0           ; bit 30 set ?
    beq     positive        ; no, jump
    bclr    d1,d0           ; yes clear bit 30
    subq.w  #1,(a0)         ; yes - decrement exponent
positive:
    move.l  d0,2(a0)        ; put mantissa in qlfloat
    move.l  a0,d0           ; set return address
    rts
#endif

