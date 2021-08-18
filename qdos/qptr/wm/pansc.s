;
;       w m _ p a n s c
;
; C68 library routine for Menu type handling: WM_PANSC
;
; Equivalent to C routine:
;
;   int wm_pansc (struct WM_wwork *, struct WM_appw *, struct WM_mctrl *)
;
; The mctrl structure is used to get information from the wm_msect function
;
; struct mctrl
; {short     pan/scroll item;
;  short     hit position
;  short     bar length
;  short     pan/scroll event}
;
;
; AMENDMENT HISTORY
; ~~~~~~~~~~~~~~~~~
;   First Version       Tony Tebby
;
;   31 Oct 93   DJW   - Added underscore to entry point name
;                     - Added error check on lnowing WMAN vector
;
;   21 Aug 94   DJW   - Added extra underscore at start of all routine names
;                       as part of implementing name hiding for QPTR routines

        .text
        .even

        .globl    __wm_pansc
        .globl    __wm__pnsc

WM.PANSC equ    $38
WW_CHID  equ    $08
SAVEREG  equ    24+4            ; size of saved registers + return address

__wm_pansc:
        movem.l d2/d3/d4/a2/a3/a4,-(sp)
        move.l  0+SAVEREG(sp),a4
        move.l  4+SAVEREG(sp),a3

        move.l  8+SAVEREG(sp),a1
        move.w  (a1)+,d2                 ; item
        move.l  (a1)+,d3                 ; pos
        move.w  (a1)+,d4                 ; event

        move.l  WW_CHID(a4),a0           ; channel ID
        bsr     __wm__pnsc
        movem.l (sp)+,d2/d3/d4/a2/a3/a4
pan_rts:
        rts

;+++
; wm__pnsc
;
; NOT C68 call compatible.  Direct call to wm.pansc
;
;---
__wm__pnsc:
        jsr     __wm_fndv
        bmi     pan_rts
        move.l  d0,a2
        jmp     WM.PANSC(a2)              ; wm_mhit

