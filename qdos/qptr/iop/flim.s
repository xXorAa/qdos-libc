;
;   i o p _ f l i m
;
; Pointer Interface routine to find where the limits of a window
; may be set with the iop_outl() call. Setting outside will give
; out of range error.
;
; Equivalent to C routine:
;
;   int iop_flim( chanid_t chid, timeout_t timeout, struct WM_wsiz *lims)
;
; AMENDMENT HISTORY
; ~~~~~~~~~~~~~~~~
;   Original Version    J. Allison
;
;   30 Oct 93   DJW   - Removed setting of _oserr.
;                     - Added underscore to entry point name
;                     - Changed for timeout parameter to be of type short
;
;   21 Aug 94   DJW   - Added extra underscore at start of all routine names
;                       as part of implementing name hiding for QPTR routines

    .text
    .even
    .globl __iop_flim

IOP_FLIM equ $6c
SAVEREG  equ 8+4            ; size of saved registers + return address

__iop_flim:
    movem.l  d2-d3,-(a7)
    moveq.l  #IOP_FLIM,d0       ; Call code
    moveq.l  #0,d2              ; extra word of zero
    move.l   0+SAVEREG(a7),a0   ; channel id
    move.w   4+SAVEREG(a7),d3   ; timeout
    move.l   6+SAVEREG(a7),a1   ; Address of result block
    trap     #3
    movem.l  (a7)+,d2-d3
    rts

