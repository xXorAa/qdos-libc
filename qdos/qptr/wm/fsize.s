;
;       w m _ f s i z e
;
; C68 library routine to Find layout size
;
; Equivalent to C routine:
;
;       short wm_fsize (short *xsize, short *ysize, wdef *def)
;
; AMENDMENT HISTORY
; ~~~~~~~~~~~~~~~~~
;   First Version       Tony Tebby
;
;   31 Oct 93   DJW   - Put into own file (was previously in wm_setup_s)
;                     - Added underscore to entry point name
;                     - Added check that WMAN address known
;
;   21 Aug 94   DJW   - Added extra underscore at start of all routine names
;                       as part of implementing name hiding for QPTR routines

        .text
        .even

        .globl    __wm_fsize

WM.FSIZE equ    $54
SAVEREG equ 12+4            ; size of saved registers + return address

__wm_fsize:
        movem.l d2/a2/a3,-(sp)
        movem.l 0+SAVEREG(sp),a1/a2/a3
        move.l  (a1),d1                 ; X size in high bytes
        move.w  (a2),d1                 ; Y size in low bytes
        jsr     __wm_chkv               ; WMAN vector base knwon ?
        bmi     fin                     ; ... NO, error exit
        move.l  d0,a0                   ; set base into address register

        jsr     WM.FSIZE(a0)            ; call vector to find size

        moveq   #0,d0                   ; clear d0
        move.w  d2,d0                   ; set return as layout number
        move.w  d1,(a2)
        swap    d1
        move.w  d1,(a1)                  ; and actual size
fin:
        movem.l (sp)+,d2/a2/a3
        rts

