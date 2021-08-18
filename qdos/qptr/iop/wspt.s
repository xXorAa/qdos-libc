;
;   i o p _ w s p t
;
; Pointer Environment routine to write a sprite on the display.
;
; Equivalent to C routine:
;
;   int iop_wspt( chanid_t chid, timeout_t timeout, short x, short y, 
;                                                struct sprite *)
;
; AMENDMENT HISTORY
; ~~~~~~~~~~~~~~~~~
;   First Version       J. Allison Pointer Interface Traps
;
;   30 Oct 93   DJW   - Removed setting of _oserr
;                     - Added underscore to entry point
;                     - Allowed for fact that parameters of type 'short' are
;                       nowe passed as 2 bytes and not 4 bytes.
;
;   26 Nov 93   DJW   - Corrected problem with wrong offsets for parameters
;                       after timeout one (Found by Phil Borman)
;
;   21 Aug 94   DJW   - Added extra underscore at start of all routine names
;                       as part of implementing name hiding for QPTR routines

    .text
    .even
    .globl __iop_wspt

IOP_WPST equ $76
SAVEREG  equ 4+4                ; size of saved registers + return address

__iop_wspt:
    move.l  d3,-(a7)
    moveq.l #IOP_WPST,d0        ; Call code
    move.l  0+SAVEREG(a7),a0    ; channel id
    move.w  4+SAVEREG(a7),d3    ; timeout
    move.l  6+SAVEREG(a7),d1    ; x and y
    move.l  10+SAVEREG(a7),a1   ; sprite address

    trap    #3

    move.l  (sp)+,d3
    rts

