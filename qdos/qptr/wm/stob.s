;
;       w m _ s t o b
;
; C68 library routine for set object WM_STIOB / WM_STLOB
;
; Equivalent to C routines:
;
;   int wm_stiob (wwork *work, char *object, short window, short object)
;   int wm_stlob (wwork *work, char *object, short item)
;
; AMENDMENT HISTORY
; ~~~~~~~~~~~~~~~~
;   First Version       Tony Tebby
;
;   31 Oct 93   DJW   - Added underscore to entry point names
;                     - Allowed for fact that parameters of type 'short' are
;                       now passed in 2 bytes and not 4 bytes as previously
;
;   21 Aug 94   DJW   - Added extra underscore at start of all routine names
;                       as part of implementing name hiding for QPTR routines

        .text
        .even

        .globl    __wm_stiob
        .globl    __wm_stlob

WM.STLOB equ    $4c
WM.STIOB equ    $50

__wm_stlob:
        moveq   #WM.STLOB,d0
        move.w  8+4(sp),d1        ; item
        bra     wmst_comm

__wm_stiob:
        moveq   #WM.STIOB,d0
        move.l  8+4(sp),d1       ; window and object

SAVEREG equ 4+4             ; size of saved registers + return address

wmst_comm:
        move.l  a4,-(sp)
        move.l  0+SAVEREG(sp),a4         ; working def
        move.l  4+SAVEREG(sp),a1        ; item
        move.w  d0,a0
        jsr     __wm_chkv               ; Do we know WMAN vector base ?
        bmi     fin                     ; ... NO, error exit

        jsr     0(a0,d0.l)              ; ... YES, call vector

fin:
        move.l  (sp)+,a4
        rts
