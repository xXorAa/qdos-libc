;
;   i o p _ s p t r
;
; Pointer Environment call to set the pointer position
;
; Equivalent to C routine:
;
;   int iop_sptr( chanid_t chid, timeout_t timeout, short *x, short *y,
;                                                  char origin_key)
;
; AMENDMENT HISTORY
; ~~~~~~~~~~~~~~~~~
;   First Version       J. Allison Pointer Interface Traps
;
;   30 Oct 93   DJW   - Removed setting of _oserr
;                     - Added underscore to entry point name
;                     - Allowed for fact that parameters of type 'short' are
;                       now passed as 2 bytes rather than 4 butes as previously
;
;   10 Jun 94   DJW   - Some of the parameters were accessed at the wrong
;                       stack offsets.
;                       (Problem and Fix from Phillipe Troin)
;
;   21 Aug 94   DJW   - Added extra underscore at start of all routine names
;                       as part of implementing name hiding for QPTR routines

    .text
    .even
    .globl __iop_sptr

IOP_SPTR equ    $7b
SAVEREG  equ    12+4            ; size of saved registers + return address

__iop_sptr:
    movem.l d2/d3/a2,-(sp)
    moveq.l #IOP_SPTR,d0        ; Call code
    move.l  0+SAVEREG(a7),a0    ; LONG: channel id
    move.w  4+SAVEREG(a7),d3    ; WORD: timeout
    move.l  6+SAVEREG(a7),a1    ; LONG: address of x co-ordinate
    move.l  (a1),d1             ; WORD << 16: .... X into high bytes
    move.l  10+SAVEREG(a7),a2   ; LONG: address of Y co-ordinate
    move.w  (a2),d1             ; WORD: ... Y into low bytes
    move.b  15+SAVEREG(a7),d2   ; BYTE: origin key

    trap    #3

    move.w  d1,(a2)             ; WORD: save new Y value
    swap    d1
    move.w  d1,(a1)             ; WORD: save new X value

    movem.l (sp)+,d2/d3/a2
    rts

