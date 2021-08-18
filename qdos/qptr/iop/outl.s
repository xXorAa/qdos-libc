;
;   i o p _ o u t l
;
; Pointer Interface call to Define a managed windows outline
;
; Equivalent to C routine:
;
; int iop_outl( chanid_t chid, timeout_t timeout, short shad_x, short shad_y,
;               short keep_flag, struct WM_wsiz *)
;
; AMENDMENT HISTORY
; ~~~~~~~~~~~~~~~~~
;   First Verion        J. Allison Pointer Interface Traps
;
;   10 Jul 93   DJW   - Removed setting of _oserr variable
;
;   24 Oct 93   DJW   - Added underscore to entry point name
;                      - Changed to allow for the fact that under C68 release 4
;                       'short' parameters are not widened to int, but are
;                       instead passed as two bytes, and that timeout_t is now
;                       a 'short' rather than a int.
;
;   21 Aug 94   DJW   - Added extra underscore at start of all routine names
;                       as part of implementing name hiding for QPTR routines

    .text
    .even
    .globl __iop_outl

IOP_OUTL equ $7a
SAVEREG equ  16+4                ; size of saved registers + return address

__iop_outl:
    movem.l d2/d3/a2/a3,-(sp)   ; save registers corrupted by call
    moveq   #IOP_OUTL,d0        ; Call code
    move.l  0+SAVEREG(sp),a0    ; LONG: Channel
    move.w  4+SAVEREG(sp),d3    ; WORD: timeout
    move.l  6+SAVEREG(sp),d1    ; WORD + WORD: shadow X and Y items
    move.w  10+SAVEREG(sp),d2   ; CHAR: keep flag
    move.l  12+SAVEREG(sp),a1   ; LONG: Window Size details

    trap    #3                

    movem.l (sp)+,d2/d3/a2/a3   ; restore saved registers
    rts

