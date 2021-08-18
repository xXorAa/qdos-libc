;
;   i o p _ p i c k
;
; Pointer Interface call to pick a window by job id or shuffle windows
;
; Equivalent to C routine:
;
;   int iop_pick( chanid_t chid, timeout_t timeout, jobid_t job_id)
;
; AMENDMENT HISTORY
; ~~~~~~~~~~~~~~~~~
; First Version         J. Allison Pointer Interface Traps
;
; 30 Oct 93     DJW   - Removed setting of _oserr
;                     - Removed need for link/unlk instructions
;                     - Added underscore to entry point name
;                     - Allowed for fact that timeout parameter is of type
;                       'short' and thus only 2 bytes in size.
;
;   21 Aug 94   DJW   - Added extra underscore at start of all routine names
;                       as part of implementing name hiding for QPTR routines

    .text
    .even
    .globl __iop_pick

IOP_PICK equ  $7c
SAVEREG  equ  8+4               ; size of saved registers + return address

__iop_pick:
    movem.l d2-d3,-(a7)
    moveq.l #IOP_PICK,d0        ; Call code
    move.l  0+SAVEREG(a7),a0    ; Channel id
    move.w  4+SAVEREG(a7),d3    ; timeout
    move.l  6+SAVEREG(a7),d1    ; job id or key
    trap    #3
    movem.l (a7)+,d2-d3
    rts

