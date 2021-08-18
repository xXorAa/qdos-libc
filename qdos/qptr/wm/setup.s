;
;       w m _ s e t u p
;
; C68 library routine to do WM_SETUP and related routines
;
; Equivalent to C routine
;
;   long wm_setup (long chid, 0,0, wdef *def, wstat *stat, wwork **work,long allc)
;   long wm_setup (long chid, -1,-1, wdef *def, wstat *stat, wwork **work)
;   long wm_setup (long chid, short xsize, short ysize, wdef *def, wstat *stat,
;                        wwork **work, long allc)
;
; AMENDMENT HISTORY
; ~~~~~~~~~~~~~~~~~
;   First Version       Tony Tebby
;
;   31 oct 93   DJW   - Moved wm_fsize() to own file
;                     - Added underscore to entry point name
;                     - Added check on WMAN vector being known
;
;   21 Aug 94   DJW   - Added extra underscore at start of all routine names
;                       as part of implementing name hiding for QPTR routines

        .text
        .even

        .globl    __wm_setup

SMS.ACHP equ    $18

WM.SETUP equ    $04
WM.SMENU equ    $08

SAVEREG equ 20+4            ; size of saved registes + return address

__wm_setup:
        movem.l d2/d3/a2-a4,-(sp)
        move.l  16+SAVEREG(sp),a4        ; pointer to working definition
        move.l  20+SAVEREG(sp),d1        ; allocation size required
        beq     wms_setup                ; ... 0 = already allocated

        tst.w   4+SAVEREG(sp)            ; size
        blt     wms_setup                ; size / position unchanged

        moveq   #SMS.ACHP,d0
        moveq   #-1,d2                   ; this job
        trap    #1                       ; allocate heap (qdos comp)
        tst.l   d0
        blt     wms_exit
        move.l  a0,(a4)                  ; set pointer to working definition

wms_setup:
        move.l  4+SAVEREG(sp),d1        ; X and Y sizes
        move.l  0+SAVEREG(sp),a0        ; channel ID
        move.l  12+SAVEREG(sp),a1       ; status area
        move.l  8+SAVEREG(sp),a3        ; window def
        move.l  (a4),a4                 ; working area

        jsr     __wm_fndv
        bmi     wms_exit
        move.l  d0,a2
        jsr     WM.SETUP(a2)             ; do setup

wms_exit:
        movem.l (sp)+,d2/d3/a2-a4
        rts

