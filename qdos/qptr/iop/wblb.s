;
;   i o p _ w b l b
;
; Pointer Environment call to write blob on the display:
;
; Equivalent to C routine:
;
; int iop_wblb( chanid_t chid, timeout_t timeout, short x, short y, 
;                           struct blob *, struct pattern *);
;
; AMENDMENT HISTORY
; ~~~~~~~~~~~~~~~~~
;   First Version       J. Allison Pointer Interface Traps
;
;   30 Oct 93   DJW   - Removed setting of _oserr
;                     - Allowed for fact that parameters of type 'short' are
;                       now passed as 2 bytes and not 4 bytes as previously.
;                     - Added underscore to entry point names.
;
;   21 Aug 94   DJW   - Added extra underscore at start of all routine names
;                       as part of implementing name hiding for QPTR routines
;
;   28 Sep 95   DJW   - Corrected problem with entry point not being visible
;                       due to being mispelt.
;                       Problem reported by Jerome Grimbert.

    .text
    .even
    .globl __iop_wblb


IOP_WBLB equ $73
SAVEREG  equ 12+4               ; size of saved registers + return address

__iop_wblb:
    movem.l d2/d3/a2,-(a7)
    moveq   #IOP_WBLB,d0        ; Call code
    move.l  0+SAVEREG(a7),a0    ; channel id
    move.w  4+SAVEREG(a7),d3    ; timeout
    move.l  6+SAVEREG(a7),d1    ; x and y co-ordiantes
    move.l  10+SAVEREG(a7),a1   ; blob address
    move.l  14+SAVEREG(a7),a2   ; pattern address
    moveq   #0,d2               ; required value in d2

    trap    #3

    movem.l (a7)+,d2/d3/a2
    rts

