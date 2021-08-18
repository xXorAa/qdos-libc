;
;   m t _ r e c h p / s m s _ r c h p
;
; routine to release an area of common heap
; equal to c routine
;   void mt_rechp( char *area )
;
; AMENDMENT HISTORY
; ~~~~~~~~~~~~~~~~~
;   20 Jul 93   DJW   - Added SMS name as additional entry point
;                     - Removed link/ulnk instruction by making all
;                       parameter access relative to a7
;
;   06 Nov 93   DJW   - Added underscore to entry point names
;
;   24 Jan 94   DJW   - Added (yet another) underscore to entry point names
;                       for name hiding purposes

    .text
    .even

    .globl __mt_rechp
    .globl __sms_rchp

SAVEREG equ 16                  ; size of saved registers

__mt_rechp:                       ; QDOS name
__sms_rchp:                       ; SMS name
    movem.l d2/d3/a2/a3,-(a7)
    moveq.l #$19,d0             ; byte code
    move.l  4+SAVEREG(a7),a0
    trap    #1
    movem.l (a7)+,d2/d3/a2/a3
    rts

