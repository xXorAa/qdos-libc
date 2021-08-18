;
;   i o p _ s w d f
;
; Pointer Environment call to set the sub-window definition list
;
; Equivalent to C routine:
;
;   int iop_swdf( chanid_t chid, timeout_t timeout, long *sub_ptr)
;
; AMENDMENT HISTORY
; ~~~~~~~~~~~~~~~~~
;   First Version       J. Allison Pointer Interface Traps
;
;   30 Oct 93   DJW   - Removed setting of _oserr
;                     - Removed need for link/ulnk instructions
;                     - Added underscore to entry point name
;                     - Allowed for fact that parametrs of type'short' are
;                       now passed as 2 bytes and not 4 bytes as previously
;
;   21 Aug 94   DJW   - Added extra underscore at start of all routine names
;                       as part of implementing name hiding for QPTR routines

    .text
    .even
    .globl  __iop_swdf

IOP_SWDF equ    $7d
SAVEREG  equ    4+4             ; size of saved registers + return address

__iop_swdf:
    move.l  d3,-(a7)
    moveq.l #IOP_SWDF,d0        ; Call code
    move.l  0+SAVEREG(a7),a0    ; Channel id
    move.w  4+SAVEREG(a7),d3    ; timeout
    move.l  6+SAVEREG(a7),a1    ; pointer to sub-window list

    trap    #3

    move.l  (a7)+,d3
    rts

