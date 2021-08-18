;
;       w m _ w d r a w
;
; C68 library routine to do WM_PULLD / PRPOS / WRSET / UNSET / WDRAW / RPTR
;
;   wm_prpos        Position Primary Window
;   wm_pulld        Pull down secondary Window
;   wm_rptr
;   wm_unset        Unset Windows
;   wm_wdraw        Draw Window
;   wm_wrset        Reset Window Defintion
;
; Equivalent to C routines:
;
;   int wm_prpos (wwork *work, short xpos, short ypos) | (wwork *work, short -1)
;   int wm_pulld (wwork *work, short xpos, short ypos) | (wwork *work, short -1)
;   int wm_rptr  (wwork *work)
;   int wm_unset (wwork *work)
;   int wm_wdraw (wwork *work)
;   int wm_wrset (wwork *work)
;
; AMENDMENT HISTORY
; ~~~~~~~~~~~~~~~~~
;   First Version       Tony Tebby
;
;   31 Oct 93   DJW   - Added underscores to entry point names
;                     - Allowed for the fact that parameters of type 'short'
;                       are now passed as 2 bytes and not 4 bytes.
;                     - Added check that we know the WMAN vector.
;
;   21 Aug 94   DJW   - Added extra underscore at start of all routine names
;                       as part of implementing name hiding for QPTR routines

        .text
        .even

        .globl    __wm_pulld
        .globl    __wm_prpos
        .globl    __wm_rptr
        .globl    __wm_unset
        .globl    __wm_wdraw
        .globl    __wm_wrset

WM.PRPOS equ    $0c
WM.PULLD equ    $10
WM.UNSET equ    $14
WM.WRSET equ    $18
WM.WDRAW equ    $1c
WM.RPTR  equ    $30


__wm_pulld:
        moveq   #WM.PULLD,d0
        bra     wmd_d1

__wm_prpos:
        moveq   #WM.PRPOS,d0

wmd_d1:
        move.l  4+4(sp),d1                ; X and Y positions

SAVEREG equ 8+4                 ; size of saved registers + return address

wmd_comm:
        movem.l d5/a4,-(sp)             ; (d5 can be smashed by wm.wdraw!)
        move.l  0+SAVEREG(sp),a4        ; working def
        move.w  d0,a0                   ; save vector offset
        jsr     __wm_chkv               ; Check we know WMAN vector
        bmi     nowman                  ; ... NO, exit 

        jsr     0(a0,d0.l)              ; ... YES, call vector

nowman:
        movem.l  (sp)+,d5/a4
        rts

__wm_rptr:
        moveq   #WM.RPTR,d0
        bra     wmd_comm

__wm_unset:
        moveq   #WM.UNSET,d0
        bra     wmd_comm

__wm_wdraw:
        moveq   #WM.WDRAW,d0
        bra     wmd_comm

__wm_wrset:
        moveq   #WM.WRSET,d0
        bra     wmd_comm


