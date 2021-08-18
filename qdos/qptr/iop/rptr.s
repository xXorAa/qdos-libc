;
;   i o p _ r p t r
;
; Pointer Interface routine to read the pointer.
;
; Equivalent to C routine:
;
;   int iop_rptr( chanid_t chid, timeout_t timeout, short *x, short *y, 
;                       unsigned short term_vect, struct *WM_prec);
;
; AMEMDMEMT HISTORY
; ~~~~~~~~~~~~~~~~~
;   First Version       J. Allison Pointer Interface Traps
;
;   30 Oct 93   DJW   - Removed setting of _oserr
;                     - Removed need for link/unlk instructions
;                     - Added underscore to entry point name
;                     - Changed to allow for parameters of type 'short' to be
;                       passed as only two bytes.
;                     - Corrected fault whereby x and y were assumed to be of
;                       type 'int' (4 bytes) despite the fact that the
;                       definition of the routine said they were type 'short'.
;
;   10 Jun 94   DJW   - Some of the parameters were accessed at the wrong
;                       stack offsets.
;                       (Problem and Fix from Phillipe Troin)
;
;   21 Aug 94   DJW   - Added extra underscore at start of all routine names
;                       as part of implementing name hiding for QPTR routines

    .text
    .even
    .globl __iop_rptr

IOP_RPTR equ $71
SAVEREG  equ 16+4               ; size of saved registers + return address

__iop_rptr:
    movem.l d2-d3/a2-a3,-(a7)
    moveq.l #IOP_RPTR,d0        ; Call code
    move.w  4+SAVEREG(a7),d3    ; WORD: timeout
    move.l  6+SAVEREG(a7),a2    ; LONG: Address of x coord
    move.l  (a2),d1             ;   WORD << 16:Get x coord into high word
    move.l  10+SAVEREG(a7),a3   ; LONG: Address of y coord
    move.w  (a3),d1             ;   WORD: Put y coord in low word
    move.w  14+SAVEREG(a7),d2   ; WORD: Get termination vector
    move.l  0+SAVEREG(a7),a0    ; LONG: Channel id
    move.l  16+SAVEREG(a7),a1   ; LONG: pointer record address
    trap    #3
    move.w  d1,(a3)             ; WORD: Restore new y coord
    swap    d1
    move.w  d1,(a2)             ; WORD: Restore new x coord
    movem.l (a7)+,d2-d3/a2-a3
    rts

