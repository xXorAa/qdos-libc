;
;   i o p _ w r s t
;
; Point Environment routine to restore a bit image to a window.
;
; Equivalent to C routine:
;
;   int iop_wrst( chanid_t chid, timeout_t timeout, char *sav_add, char keep)
;
; AMENDMENT HISTORY
; ~~~~~~~~~~~~~~~~~
;   First Version       J. Allison Pointer Interface Traps
;
;   30 oct 93   DJW   - Removed setting of _oserr
;                     - Removed need for link/ulnk instructions
;                     - Added underscore to entry point name
;                     - Allowed for fact that parameters of type 'short' are
;                       now passed in 2 bytes, and not 4 bytes.
;
;   21 Aug 94   DJW   - Added extra underscore at start of all routine names
;                       as part of implementing name hiding for QPTR routines

    .text
    .even
    .globl __iop_wrst

IOP_WRST equ    $7f
SAVEREG  equ    8+4             ; size of saved registers + return address

__iop_wrst:
    movem.l  d2-d3,-(a7)
    moveq.l #$7F,d0             ; Call code
    move.l  0+SAVEREG(a7),a0    ; Channel id
    move.w  4+SAVEREG(a7),d3    ; timeout
    move.l  6+SAVEREG(a7),a1    ; address of save area
    move.b  11+SAVEREG(a7),d2   ; Flag to keep area

    trap    #3

    movem.l  (a7)+,d2-d3
    rts

