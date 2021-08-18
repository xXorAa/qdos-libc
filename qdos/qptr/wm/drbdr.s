;
;   w m _ c l b d r     /   w m _ d r b d r
;
; C68 lWindow Manager ibrary routine for WM_DRBDR and clear border
;
; Equivalent to C routines
;
;   int wm_clbdr (wwork *work)
;   int wm_drbdr (wwork *work)
;
; AMENDMENT HISTORY
; ~~~~~~~~~~~~~~~~~
;   First Version       Tony Tebby
;
;   30 Oct 93   DJW   - Added underscores to entry point names
;                     - Use support routine to find WMAN vector
;
;   21 Aug 94   DJW   - Added extra underscore at start of all routine names
;                       as part of implementing name hiding for QPTR routines

    .text
    .even

    .globl    __wm_drbdr
    .globl    __wm_clbdr

WM.DRBDR equ    $44

ww_wstat equ    $00
ww_chid  equ    $08

ws_ciact equ    $2c
ws_citem equ    $30


;+++
;
; This routine checks if there is a current item, and if so it clears it
; following the actions described in the QPTR manual for using WM.DRBDR to
; clear an item.
;
;---
__wm_clbdr:
        move.l  4(sp),a1                 ; working definition
        move.l  ww_chid(a1),a0           ; channel ID
        move.l  ww_wstat(a1),a1          ; status area
        tas     ws_citem(a1)
        bne     wmd_rts
        move.l  ws_ciact(a1),d0          ; current item action routine
        beq     wmd_draw                 ; ... none
        clr.l   ws_ciact(a1)             ; clear it
        move.l  d0,-(sp)                 ; and call it
        rts

;+++
;
; Extended form of WM_DRBDR finds the channel ID and status area from the
; working definition
;
;---
__wm_drbdr:
        move.l  4(sp),a1                 ; working definition
        move.l  ww_chid(a1),a0           ; channel ID
        move.l  ww_wstat(a1),a1          ; status area

wmd_draw:
        jsr     __wm_fndv               ; try to find WMAN vector
        bmi     wmd_rts                 ; ... exit if error
        move.l  a2,-(sp)                ; save register variable
        move.l  d0,a2                   ; put vector into address register

        jsr     WM.DRBDR(a2)            ; draw border

        move.l  (sp)+,a2                ; restore register variable
wmd_rts:
        rts

