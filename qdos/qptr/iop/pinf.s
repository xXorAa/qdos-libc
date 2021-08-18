;
;   i o p _ p i n f
;
; Pointer Interface routines to get pointer info and the
; Window manager vector.
;
;   iop_pinf        Standard Pointer Interface Call
;
; Equivalent to C routine:
;
;   char *iop_pinf( chanid_t chid, timeout_t timeout, long *version)
;
; Returns:
; Returns address of window manager vector or zero on error.
;
; AMENDMENT HISTORY
; ~~~~~~~~~~~~~~~~~
; First Version         J. Allison Pointer Interface Traps
;
;   30 Oct 93   DJW   - Removed setting of _oserr
;                     - Added underscore to entry point name
;                     - Changed to allow for the fact that timeout parameter
;                       is 2 bytes in sizee and not 4 bytes.
;                     - Changed to return error code (which is negative) rather
;                       than 0 if an error occurred.
;                     - Added store of WMAN vector in global variable
;
;   30 Dec 93   DJW   - Corrected bug where ther registers saved and restored
;                       did not correspond.  (Reported by Johnathan Hudson).
;
;   21 Aug 94   DJW   - Added extra underscore at start of all routine names
;                       as part of implementing name hiding for QPTR routines

    .text
    .even
    .globl __iop_pinf

IOP_PINF equ $70

SAVEREG  equ 4+4                ; size of saved registers + return address

__iop_pinf:
    move.l  d3,-(a7)            ; save potential register variable
    moveq.l #IOP_PINF,d0        ; code
    move.l  0+SAVEREG(a7),a0    ; chid
    move.w  4+SAVEREG(a7),d3    ; timeout

    trap    #3

    tst.l   d0                  ; error occurred ?
    bne     fin                 ; ... YES, exit with error code as reply
    move.l  6+SAVEREG(a7),a0
    move.l  d1,(a0)             ; save pointer version number.
    move.l  a1,d0               ; set vector address as reply
    move.l  d0,__WM_vector      ; ... and save in WMAN vector address
fin:
    movem.l (a7)+,d3
    rts

