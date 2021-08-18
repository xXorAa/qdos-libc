;
;   w m _ c h w i n
;
; Window Manager routine to change window position or size
;
; Equivalent to C routine:
;
;   int wm_chwin (wwork *ww, short *xdiff, short *ydiff)
;
;       ww      = pointer to working definition
;       xdiff   = pointer to storage for xdiff (change size)
;       ydiff   = pointer to storage for ydiff (change size)
;
; returns:
;       0       OK
;       -ve     QDOS error, pt..wsiz if change size required
;
; AMENDMENT HISTORY
; ~~~~~~~~~~~~~~~~~
;   First Version           Tony Tebby
;
;   30 Oct 93   DJW   - Added underscores to entry point name
;                     - Passed additional parameter to make code re-entrant
;                       (and thus suitable for RLL libraries)
;
;   21 Aug 94   DJW   - Added extra underscore at start of all routine names
;                       as part of implementing name hiding for QPTR routines

    .text
    .even
    .globl    __wm_chwin

PT..WSIZ equ    20
WM.CHWIN equ    $40
SAVEREG  equ 16+4                ; size of saved registers + return address

__wm_chwin:
        movem.l d2/d4/d7/a4,-(a7)
        move.l  0+SAVEREG(a7),a4        ; working definition
        jsr     __wm_chkv               ; get window manager vector
        bmi     wcw_exit                ; ... exit if not known
        move.l  d0,a0                   ; otherwise into address register
        jsr     WM.CHWIN(a0)            ; do setup
        blt     wcw_exit
        cmp.l   #PT..WSIZ,d4            ; event?
        bne     wcw_exit                ; ... no

        move.l  8+SAVEREG(sp),a0        ; ydiff
        move.w  d1,(a0)

        move.l  4+SAVEREG(sp),a0         ; xdiff
        swap    d1
        move.w  d1,(a0)

        move.l  d4,d0

wcw_exit:
        movem.l (sp)+,d2/d4/d7/a4
        rts

