;
;   i o p _ l b l b
;
; Pointer Interface call to write a line of blobs on the display.
;
; equivalent to C routine:
;
;   int iop_lblb( chanid_t chid, timeout_t timeout, short start_x, short start_y,
;                              short finish_x, short finish_y
;                              struct blob *, struct pattern *);
;
; AMENDMENT HISTORY
; ~~~~~~~~~~~~~~~~
;   First version       J. Allison
;
;   30 Oct 93   DJW   - Removed setting of _oserr.
;                     - Added underscore to entry point name
;                     - Changed to allow for the fact that with C68 v4, the
;                       parameters of type 'short' are passed as only 2 bytes.
;                     - Removed need for link/unlk instructions by making all
;                       parameter access relative to the stack pointer A7
;
;   21 Aug 94   DJW   - Added extra underscore at start of all routine names
;                       as part of implementing name hiding for QPTR routines
;
;   12 Sep 95   DJW   - Changed slightly to move 2 word parameters with a long
;                       move as slightly reduces code size.
;
;   28 Sep 95   DJW   - Fixed problem with not correctly taking stored registers
;                       off stack at end of function.
;                       (Problem reported by Jerome Grimbert)

    .text
    .even
    .globl __iop_lblb

IOP_LBLB equ $74
SAVEREG  equ 12+4               ; size of saved registers + return address

__iop_lblb:
    movem.l d2/d3/a2,-(a7)      ; save registers corrupted by call
    moveq.l #IOP_LBLB,d0        ; Call code
    move.l  0+SAVEREG(a7),a0    ; Channel id
    move.w  4+SAVEREG(a7),d3    ; timeout
    move.l  6+SAVEREG(a7),d1    ; start X/Y coord
    move.l  10+SAVEREG(a7),d2   ; finish x/y coord
    move.l  14+SAVEREG(a7),a1   ; Blob defn.
    move.l  18+SAVEREG(a7),a2   ; Pattern defn.

    trap    #3                  ; call PE

    movem.l (a7)+,d2/d3/a2      ; restore saved registers
    rts

