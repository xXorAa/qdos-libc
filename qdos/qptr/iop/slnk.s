;
;   i o p _ s l n k
;
; Pointer Environment routine to set bytes in linkage block.
;
; equivalent to C routine:
;
;   char *iop_slnk(chanid_t chid, timeout_t timeout, char *bytes,
;                                        short pos,short num);
;
; Returns:
;       +ve     Address of linkage block
;       -ve     QDOS/SMS error code.
;
; AMEMDMEMT HISTORY
; ~~~~~~~~~~~~~~~~~
;   First Version       J. Allison Pointer Interface Traps
;
;   30 oct 93   DJW   - Removed setting of _oserr
;                     - Removed need for link/ulnk instructions
;                     - Added underscore to entry point name
;                     - Allowed for fact that parameters of type 'short' are
;                       now passed as 2 bytes and not 4 bytes.
;                     - Now Returns error code rathen than 0 if error occurs.
;
;   21 Aug 94   DJW   - Added extra underscore at start of all routine names
;                       as part of implementing name hiding for QPTR routines

    .text
    .even
    .globl __iop_slnk

IOP_SLNK equ $6f
SAVEREG  equ 8+4                ; size of saved registers + return address

__iop_slnk:
    movem.l d2-d3,-(a7)
    moveq.l #IOP_SLNK,d0        ; code
    move.l  0+SAVEREG(a7),a0    ; chid
    move.w  4+SAVEREG(a7),d3    ; timeout
    move.l  6+SAVEREG(a7),a1    ; pointer to data to set
    move.w  10+SAVEREG(a7),d1   ; position
    move.w  12+SAVEREG(a7),d2   ; number
    trap    #3
    tst.l   d0                  ; error occurred ?
    bne     OUT                 ; ... YES exit with error code
    move.l  a1,d0               ; ... NO, set linkage address as reply
OUT:
    movem.l (a7)+,d2-d3
    rts

