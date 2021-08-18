;
;   i o p _ w s a v
;
; Pointer Environment call to save a bit image from a window.
;
; Equivalent to C routine:
;
;   int iop_wsav( chanid_t chid, tiemout_t timeout, char *sav_add, long len)
;
; AMENDMENT HISTORY
; ~~~~~~~~~~~~~~~~~
;   First Version       J. Allison Pointer Interface Traps
;
;   30 Oct 93   DJW   - Removed setting of _oserr
;                     - Removed need for link/ulnk instructions
;                     - Changed to allow for the fact that parameters of type
;                       'short' are now 2 bytes and not 4 bytes in size.
;
;   21 Aug 94   DJW   - Added extra underscore at start of all routine names
;                       as part of implementing name hiding for QPTR routines

    .text
    .even
    .globl __iop_wsav

IOP_WSAV equ    $7e
SAVEREG  equ    4+4             ; size of saved registers + return address

__iop_wsav:
    move.l  d3,-(a7)
    moveq.l #IOP_WSAV,d0        ; Call code
    move.l  0+SAVEREG(a7),a0    ; Channel id
    move.w  4+SAVEREG(a7),d3    ; timeout
    move.l  6+SAVEREG(a7),a1    ; address of save area
    move.l  10+SAVEREG(a7),d1   ; Length of save area

    trap    #3

    move.l  (a7)+,d3
    rts

