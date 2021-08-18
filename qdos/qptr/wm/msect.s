;
;       w m _ m s e c t
;
; C68 library routine for Menu type handling: WM_MSECT
;
; Equivalent to C routine:
;
; int   wm_msect(struct WM_work *, struct WM_appw *, short xpos, short ypos, 
;                                short key, short event, struct WM_mctrl *)
;
; The mctrl structure is used to pass information to the wm_pansc function
;
;   struct WM_mctrl {
;       {short     pan/scroll item;
;       short     hit position
;       short     bar length
;       short     pan/scroll event}
;
; The function returns an error code (-ve) 0 or pan/scroll item (+ve)
;
; AMENDMENT HISTORY
; ~~~~~~~~~~~~~~~~~
;   First Version       Tony Tebby
;
;   31 Oct 93   DJW   - Added underscore to entry point name
;                     - Allowed for fact that parameters of type 'short' are
;                       now passed in 2 bytes and not 4 bytes as previously
;                     - Added error check on knowing WMAN vector
;
;   21 Aug 94   DJW   - Added extra underscore at start of all routine names
;                       as part of implementing name hiding for QPTR routines

        .text
        .even

        .globl    __wm_msect

WM.MSECT equ    $48
ww_chid  equ    $08
SAVEREG  equ    24+4            ; size of saved registers + return address

__wm_msect:
        movem.l d2/d3/d4/a2/a3/a4,-(sp)
        move.l  0+SAVEREG(sp),a4        ; Working Definition
        move.l  4+SAVEREG(sp),a3        ; Sub-window definition
        move.l  8+SAVEREG(sp),d1        ; X and Y pointer positions
        move.w  12+SAVEREG(sp),d2       ; key
        move.w  14+SAVEREG(sp),d4       ; event

        move.l  16+SAVEREG(sp),a1
        clr.l   (a1)+
        clr.l   (a1)+                    ; clear control structure

        move.l  ww_chid(a4),a0           ; channel ID

        jsr     __wm_fndv               ; can we get WMAN vector ?
        bmi     wms_exit                ; ... NO, error exit
        move.l  d0,a2
        jsr     WM.MSECT(a2)             ; wm_msect

        blt     wms_exit
        move.b  d4,-(a1)                 ; event
        subq.l  #1,a1
        move.l  d3,-(a1)                 ; position
        move.b  d0,-(a1)                 ; item
wms_exit:
        movem.l (sp)+,d2/d3/d4/a2/a3/a4
        rts

