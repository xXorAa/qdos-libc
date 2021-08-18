;
;       w m _ m d r a w
;
; C68 library routines WM_MDRAW / WM_INDEX /WM_ UPBAR
;
; Equivalent to C routines:
;
;   int wm_index (wwork *work, swdef *sw)
;   int wm_mdraw (wwork *work, swdef *sw, char select)
;   int wm_upbar (wwork *work, swdef *sw, short x_section, y_section)
;
; AMENDMENT HISTORY
; ~~~~~~~~~~~~~~~~~
;   First Version       Tony Tebby
;
;   31 Oct 93   DJW   - Added underscores to entry point names
;                     - Allowed for fact that parametrs of type 'short' are
;                       now passed in 2 bytes and not 4 bytes as previously
;                     - Added check on knowing WMAN vector
;
;   28 Nov 93   DJW   - Fixed discrepancy between number of registers saved
;                       and number of registers restored.
;                       (Problem + fix reported by Phil Borman)
;
;   21 Aug 94   DJW   - Added extra underscore at start of all routine names
;                       as part of implementing name hiding for QPTR routines

        .text
        .even

        .globl    __wm_mdraw
        .globl    __wm_index
        .globl    __wm_upbar

WM.MDRAW  equ   $20
WM.INDEX  equ   $24
WM.UPBAR  equ   $70

ww_chid   equ   $08

__wm_upbar:
        moveq   #WM.UPBAR,d0
        bra     wmd_comm

__wm_index:
        moveq   #WM.INDEX,d0
        bra     wmd_comm

__wm_mdraw:
        moveq   #WM.MDRAW,d0

SAVEREG equ 16+4                ; size of saved registers + return address

wmd_comm:
        movem.l d3/a2-a4,-(sp)
        move.w  d0,a2               ; save vector required
        jsr     __wm_fndv           ; do we know WMAN vector ?
        bmi     wmd_rts             ; ... NO, then exit with error
        move.l  d0,a1               ; save WMAN vector base for later
        move.l  0+SAVEREG(sp),a4    ; working def
        move.l  4+SAVEREG(sp),a3
        move.l  8+SAVEREG(sp),d0    ; X and Y section (for wm_upbar)
        move.b  9+SAVEREG(sp),d3    ; select (for wm_mdraw)
        move.l  ww_chid(a4),a0      ; channel ID

        jsr     0(a1,a2.w)

wmd_rts:
        movem.l (sp)+,d3/a2-a4
        rts

