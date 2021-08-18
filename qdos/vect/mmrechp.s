;
;   m m _ r e c h p / m e m _ r c h p
;
; routine to release an area of common heap
; equal to c routine.
;   void mm_rechp( char *area )
;
; AMENDMENT HISTORY
; ~~~~~~~~~~~~~~~~~
;   24 Jul 93   DJW   - First version (based on mt_rechp() code).
;
;   06 Nov 93   DJW   - Added underscore to entry point names
;
;   24 Jan 94   DJW   - Added (yet another) underscore to entry point names
;                       for name hiding purposes

    .text
    .even

    .globl __mm_rechp         ; QDOS name for call
    .globl __mem_rchp         ; SMS name for call

SAVEREG equ 16                  ; size of saved registers

__mm_rechp:
__mem_rchp:
    movem.l d2/d3/a2/a3,-(a7)
    move.l  4+SAVEREG(a7),a0
    move.w  $c2,a2              ; vector required
    jsr     (a2)
    movem.l (a7)+,d2/d3/a2/a3
    rts

