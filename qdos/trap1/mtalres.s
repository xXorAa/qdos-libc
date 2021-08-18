;
;   m t _ a l r e s / s m s _ a r p a
;
; routine to allocate area in resident procedure area.
; equal to C routine
;
;   char *mt_alres( long size)
;
; returns:
;       success     address of memory on success
;       failure     (negative) error code
;
; AMENDMENT HISTORY:
; ~~~~~~~~~~~~~~~~~
;   24 Jul 93   DJW   - First version
;
;   06 Nov 93   DJW   - Added underscore to entry point names
;
;   24 Jan 94   DJW   - Added (yet another) underscore to entry point names
;                       for name hiding purposes

    .text
    .even
    .globl __mt_alres                 ; QDOS name for call
    .globl __sms_arpa                 ; SMS name for call

SAVEREG equ 16                  ; size of saved registers

__mt_alres:
__sms_arpa: 
    movem.l d2/d3/a2/a3,-(a7)
    moveq.l #$e,d0              ; byte code
    move.l  4+SAVEREG(a7),d1    ; size
    trap    #1
    tst.l   d0                  ; OK ?
    bne     fin                 ; ... NO, exit with error code
    move.l  a0,d0               ; address of area
fin:
    movem.l (a7)+,d2/d3/a2/a3
    rts

