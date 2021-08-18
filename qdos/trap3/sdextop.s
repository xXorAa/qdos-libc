;
;   s d _ e x t o p / i o w _ x t o p
;
; routine to do screen extended operation
; equivalent to c routine
;   int sd_extop( long chan, int timeout, int (*rtn)(), int paramd1,
;                       int paramd2, char *parama1)
;
; NOTE. The routine "rtn" is assumed to be in assembler so that it can
;       use the register values that are set up.
;
; AMENDMENT HISTORY
; ~~~~~~~~~~~~~~~~~
;   11 jul 93   DJW   - Removed setting of _oserr.
;                     - Removed link/ulnk instructions by making parameter
;                       access relative to a7
;   24 Jul 93   DJW   - Added SMS entry point
;
;   06 Nov 93   DJW   - Added underscore to entry point name
;                     - Allowed for fact that parameters of type 'short' are
;                       now passed as 2 bytes and not 4 bytes as previously.
;
;   20 Jan 94   DJW   - Added (yet another) underscore to entry point names
;                       for name hiding purposes

    .text
    .even

    .globl  __sd_extop        ; QDOS name for call
    .globl  __iow_xtop        ; SMS name for call

SAVEREG equ 16+4        ; size of saved registers + return addrerss

__sd_extop:
__iow_xtop:
    movem.l d2/d3/a2/a3,-(a7)
    moveq.l #$9,d0              ; byte code for sd_extop
    move.l  0+SAVEREG(a7),a0    ; channel id
    move.w  4+SAVEREG(a7),d3    ; timeout
    move.l  6+SAVEREG(a7),a2    ; operation to perform
    lea.l   10+SAVEREG(a7),a3   ; address of parameters
    movem.l (a3),d1/d2/a1       ; get them
    trap    #3
    movem.l (a7)+,d2/d3/a2/a3
    rts

