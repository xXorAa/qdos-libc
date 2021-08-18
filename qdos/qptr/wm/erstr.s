;
;   w m _ e r s t r
;
; C68 Window Manager library routine to get QDOS error string
;
; Eqivalent to C routine:
;
;   int wm_erstr (long error, QL_TEXT *name)
;
; AMENDMENT HISTORY
; ~~~~~~~~~~~~~~~~~
;   First Vesion        Tony Tebby
;
;   30 Oct 93   DJW   - Added underscore to name
;                     - Added error exit if WMAN vector not set
;
;   21 Aug 94   DJW   - Added extra underscore at start of all routine names
;                       as part of implementing name hiding for QPTR routines
 
    .text
    .even

    .globl    __wm_erstr

WM.ERSTR equ    $74

__wm_erstr:
     movem.l $4(sp),d0/a1        ; error / name buffer
     jsr     __wm_chkv           ; Do we know WMAN vector ?
     bmi     fin                 ; ... NO, take error exit
     move.l  d0,a0               ; ... YES, then set up

     jsr     WM.ERSTR(a0)        ; to jump to it

fin:
     rts

