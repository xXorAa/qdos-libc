;
;       w m _ a c t i o n
;
; C68 action routine interface
;
; AMENDMENT HISTORY
; ~~~~~~~~~~~~~~~~~
;   First Version       Tony Tebby
;
;   31 Oct 93   DJW   - Added underscore to entry points
;
;   28 Nov 93   DJW   - Changed to take account of fact that parameters of
;                       type short are now passed as 2 bytes and not 4.
;                       Problem identified and reported by Phil Borman
;
;   21 Aug 94   DJW   - Added extra underscore at start of all routine names
;                       as part of implementing name hiding for QPTR routines
;
;   21 Feb 97   DJW   - The __wm_hitaw routine upgraded to also pass in the
;                       timeout parameter as the last value.  This is to
;                       support the latest SMSQ/E event mechanisms.
;                       (change supplied by Jonathan Hudson).

        .text
        .even

        .globl    __wm_actli
        .globl    __wm_hitaw
        .globl    __wm_actme
        .globl    __wm_ctlaw
        .globl    __wm_drwaw

ww_chid  equ    $08
ww_xorg  equ    $24

wwa_xorg equ    $04

;+++
; C68 Application Sub-Window Draw routine prologue.
;
; This routine should be called on entry to a C68 application sub-window draw
; routine. The draw routine should be a LONG function.
;
; This routine sets up the stack as if the function had been called from C68
; with the parameters as follows:
;
; .. (wwork *, subw *, short xorg, short yorg)
;
; The function should return 0, or error code (-ve)
;
;---
__wm_drwaw:
        move.l  (sp)+,a1                ; return address
        move.l  (a1),a1                 ; C68 routine to be called
        movem.l d1/d7/a0,-(sp)

        move.l  d7,-(sp)                ; origin x and y
        move.l  a3,-(sp)                ; app sw
        move.l  a4,-(sp)                ; working def

        jsr     (a1)                    ; call users routine

        add.w   #12,sp                  ; tidy up stack
        movem.l (sp)+,d1/d7/a0
        tst.l   d0                      ; set reply condition codes
        rts

;+++
; C68 Application Sub-Window Control routine prologue.
;
; This routine should be called on entry to a C68 application sub-window control
; routine. The control routine must be a LONG function.
;
; This routine sets up the stack as if the function had been called from C68
; with the parameters as follows:
;
; .. (wwork *, subw *, wstat *, short bpos, short blen, short item, short event)
;
; The function should return 0, an error code (-ve) or a window event number
;
;---
__wm_ctlaw:
        move.l  d3,d1            ; fudge the params
;+++
; C68 Menu Action Action routine prologue.
;
; This routine should be called on entry to a C68 menu action routine. The
; action routine must be a LONG function.
;
; This routine sets up the stack as if the function had been called from C68
; with the parameters as follows:
;
;.(wwork *, subw *, char *mstat, short col, short row, short item, short event)
;
; The function should return 0, an error code (-ve) or a window event number
;
;---
__wm_actme:

;+++
; C68 Loose Menu Item Action routine prologue.
;
; This routine should be called on entry to a C68 loose menu item action
; routine.
; The action routine must be a LONG function.
;
; This routine sets up the stack as if the function had been called from C68
; with the parameters as follows:
;
; .. (wwork *, litm *, wstat *, short xpos, short ypos, short key, short event)
;
; The function should return 0, an error code (-ve) or a window event number
;
;---
__wm_actli:
        move.l  (sp)+,a0                 ; return address
        move.l  (a0),a0                  ; C68 routine
        move.w  d4,-(sp)                ; SHORT:    event
        move.w  d2,-(sp)                ; SHORT:    item
        move.l  d1,-(sp)                ; SHORT x 2:    clo and row
        move.l  a1,-(sp)
        move.l  a3,-(sp)
        move.l  a4,-(sp)

        jsr     (a0)

        add.w   #20,sp                  ; clean up the stack
        move.l  ww_chid(a4),a0          ; restore channel ID
        tst.l   d0                      ; return?
        ble     wma_noev                ; ... no, or error
        move.l  d0,d4                   ; ... yes, set event
        moveq   #0,d0
        rts

wma_noev:
        moveq   #0,d4
        tst.l   d0
        rts
;+++
; C68 Application Sub-Window Hit routine prologue.
;
; This routine should be called on entry to a C68 application sub-window hit
; routine. The action routine must be a LONG function.
;
; This routine sets up the stack as if the function had been called from C68
; with the parameters as follows:
;
; .. (wwork *, subw *, wstat *, short xpos, short ypos, short key, short event)
;
; The function should return an error code (-ve) or a timeout 0-32767 or 65535)
;
;---
__wm_hitaw:
        move.l  (sp)+,a2                 ; return address
        move.l  (a2),a2                  ; C68 routine
        movem.l d1/a0,-(sp)              ; save these
        sub.l   wwa_xorg(a3),d1
        sub.l   ww_xorg(a4),d1           ; sub window relative pointer position

        move.w  d3,-(sp)                 ; timeout value
        move.w  d4,-(sp)                 ; SHORT: event
        move.w  d2,-(sp)                 ; SHORT: key
        move.l  d1,-(sp)                 ; SHORT x 2 : x and ypos
        move.l  a1,-(sp)
        move.l  a3,-(sp)
        move.l  a4,-(sp)

        jsr     (a2)

        add.w   #22,sp                   ; clean up the stack
        movem.l (sp)+,d1/a0
        tst.l   d0                       ; return?
        blt     wma_rts                  ; ... no error
        move.l  d0,d3                    ; ... yes, set timeout
        moveq   #0,d0
wma_rts:
        tst.l   d0
        rts

