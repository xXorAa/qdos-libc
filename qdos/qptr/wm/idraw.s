;
;       w m _ i d r a w
;
; C68 library routine for Partial DRAW: WM_IDRAW / LDRAW
;
; Equivalent to C routines
;
;   int wm_idraw (wwork *work, long ibits)
;   int wm_ldraw (wwork *work, char select)
;
; AMENDMENT HISTORY
; ~~~~~~~~~~~~~~~~~
;   First Routine       Tony Tebby
;
;   31 Oct 93   DJW   - Added underscore to entry point names
;
;   21 Aug 94   DJW   - Added extra underscore at start of all routine names
;                       as part of implementing name hiding for QPTR routines

        .text
        .even

        .globl    __wm_idraw
        .globl    __wm_ldraw

WM.LDRAW  equ   $2c
WM.IDRAW  equ   $3c


ww_chid   equ   $08

__wm_idraw:
        moveq   #WM.IDRAW,d0
        move.l  4+4(sp),d1
        bra     wld_comm

__wm_ldraw:
        moveq   #WM.LDRAW,d0
        tst.b   1+4+4(sp)         ; selective?
        sne     d1

SAVEREG equ 8+4                 ; Size of saved registers + start address

wld_comm:
        movem.l d3/a4,-(sp)
        move.l  d1,d3            ; selective
        move.l  0+SAVEREG(sp),a4 ; working def
        move.l  ww_chid(a4),a0   ; channel ID
        move.w  d0,a1
        jsr     __wm_fndv        ; check if WMAN vector known
        bmi     wld_rts          ; ... NO, error exit

        jsr     0(a1,d0.l)

wld_rts:
        movem.l (sp)+,d3/a4
        rts

