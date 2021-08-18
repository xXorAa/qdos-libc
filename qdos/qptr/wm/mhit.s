;
;       w m _ m h i t
;
; C68 library routine for Menu type handling: WM_MHIT 
;
; Equivalent to C routine:
;
;   int wm_mhit struct WM_(wwork *,struct WM_ appw *, short xpos, short ypos, 
;                                       short key, short event)
;
; AMENDMENT HISTORY
; ~~~~~~~~~~~~~~~~~
;   First Version       Tony Tebby
;
;   15 Jun 93   DJW   - Added change to draw border around current item when
;                       using wm_mhit().
;                       (fix supplied by Erik Slagter)
;
;   31 Oct 93   DJW   - Added underscore to entry point
;                     - Added check that WMAN vector known
;                     - Allowed for fact that parameters of type 'short' are
;                       now passed as 2 bytes and not 4 bytes as previously
;
;   26 Nov 93   DJW   - For timeout reply, only two bytes were being set
;
;   21 Aug 94   DJW   - Added extra underscore at start of all routine names
;                       as part of implementing name hiding for QPTR routines

        .text
        .even

        .globl    __wm_mhit
        .globl    __wm__mhit

ERR_NC   equ    -1

WM.MHIT  equ    $34
WW_CHID  equ    $08
SAVEREG  equ    24+4        ; size of saved registers + return address

__wm_mhit:
        movem.l d2/d3/d4/a2/a3/a4,-(sp)
        move.l  0+SAVEREG(sp),a4
        move.l  4+SAVEREG(sp),a3
        move.l  8+SAVEREG(sp),d1        ; X and Y positions
        move.w  12+SAVEREG(sp),d2       ; key
        move.w  14+SAVEREG(sp),d4       ; event
        move.l  WW_CHID(a4),a0          ;                      DJW 15/06/93

        bsr     __wm__mhit              ; standard hit

        bne     wmh_exit
        moveq   #ERR_NC,d0              ; set timeout ?
wmh_exit:
        movem.l (sp)+,d2/d3/d4/a2/a3/a4
wmn_rts:
        rts

;+++
; wm__mhit
;
; NOT C68 call compatible.  Direct call to wm.mhit.
;
;---
__wm__mhit:
        jsr     __wm_fndv
        bmi     wmn_rts
        move.l  d0,a2
        jmp     WM.MHIT(a2)              ; wm_mhit

