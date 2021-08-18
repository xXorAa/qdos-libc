;
;   w m _ c l u n s
;
; C68 Window Manager routine to do WM_UNSET followed by CLOSE
;
; Equivalent to C routine
;
;   int wm_cluns (wwork *work)
;
; AMENDMENT HISTORY
; ~~~~~~~~~~~~~~~~~
;   First Version       Tony Tebby
;
;   30 Oct 93   DJW   - Added underscore to entry point names
;                     - Added erro check on wm_unset working OK
;
;   21 Aug 94   DJW   - Added extra underscore at start of all routine names
;                       as part of implementing name hiding for QPTR routines

        .text
        .even

        .globl    __wm_cluns

ww_chid  equ    $08
ioa.clos equ    2

__wm_cluns:
        move.l  4(sp),-(sp)
        jsr     __wm_unset              ; unset
        move.l  (sp)+,a0                ; working definition
        tst.l   d0                      ; worked OK ?
        bmi     fin                     ; ... NO, then exit immediately
        move.l  ww_chid(a0),a0          ; channel ID
        moveq   #ioa.clos,d0            ; close it
        trap    #2
fin:
        rts

