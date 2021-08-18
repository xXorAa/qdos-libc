;
;   i o p _ s p r y
;
; Pointer Environment call to spray a blob on the display:
;
; Equivalent to C routine:
;
; int iop_spry( chanid_t chid, timeout_t timeout, short x, short y, 
;                           struct blob *, struct pattern *, long no_pixels)
;
;                   18               1C
; AMENDMENT HISTORY
; ~~~~~~~~~~~~~~~~~
;   First Version       J. Allison Pointer Interface Traps
;
;   30 Oct 93   DJW   - Removed setting of _oserr
;                     - Allowed for fact that parameters of type 'short' are
;                       now passed as 2 bytes and not 4 bytes as previously.
;                     - Added underscore to entry point name.
;
;   21 Aug 94   DJW   - Added extra underscore at start of all routine names
;                       as part of implementing name hiding for QPTR routines

    .text
    .even
    .globl __iop_spry

IOP_SPRY equ    $77
SAVEREG equ 12+4                ; size of saved registers + return address

__iop_spry:
    movem.l d2/d3/a2,-(sp)
    moveq   #IOP_SPRY,d0        ; Call code
    move.l  0+SAVEREG(a7),a0    ; channel id
    move.w  4+SAVEREG(a7),d3    ; timeout
    move.l  6+SAVEREG(a7),d1    ; x and y co-oridnates
    move.l  10+SAVEREG(a7),a1   ; blob address
    move.l  14+SAVEREG(a7),a2   ; pattern address
    move.l  18+SAVEREG(a7),d2   ; Number of pixels

    trap    #3

    movem.l (sp)+,d2/d3/a2
    rts

