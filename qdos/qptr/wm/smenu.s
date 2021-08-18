;
;       w m _ s m e n u
;
; C68 library routine to do WM_SMENU
;
; Equivalent to C routine
;
;   int wm_smenu (short xscale, short yscale, wstat *stat, wdef **def, wwork **work)
;
; AMENDMENT HISTORY
; ~~~~~~~~~~~~~~~~~
;   31 Oct 93   DJW   - First Version.  Based on the wm_setup() routine.
;
;   21 Aug 94   DJW   - Added extra underscore at start of all routine names
;                       as part of implementing name hiding for QPTR routines

        .text
        .even

        .globl    __wm_smenu

WM.SMENU equ    $08

SAVEREG equ 20+4            ; size of saved registes + return address

__wm_smenu:
        movem.l d2/d3/a2-a4,-(sp)
        move.w  0+SAVEREG(sp),d1        ; X scaling
        move.w  2+SAVEREG(sp),d2        ; Y scaling
        move.l  4+SAVEREG(sp),a1        ; status area
        move.l  8+SAVEREG(sp),a3        ; pointer to window definition
        move.l  (a3),a3                 ; working definition
        move.l  12+SAVEREG(sp),a4       ; pointer to working definition
        move.l  (a4),a4                 ; working area

        jsr     __wm_chkv
        bmi     wms_exit
        move.l  d0,a2
        jsr     WM.SMENU(a2)            ; do setup

        move.l  8+SAVEREG(sp),a0        ; pointer to window definition
        move.l  a3,(a0)                 ; working definition
        move.l  12+SAVEREG(sp),a0       ; pointer to working definition
        move.l  a4,(a0)                 ; working area

wms_exit:
        movem.l (sp)+,d2/d3/a2-a4
        rts

