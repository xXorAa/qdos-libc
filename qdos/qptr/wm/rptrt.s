;
;   w m _ r p t r t
;
; C68 lWindow Manager library routine for WM_RPTRT
;
; Equivalent to C routines
;
;   int wm_rptrt (wwork *work, tiemout_t t, unsigned short evnt);
;
; AMENDMENT HISTORY
; ~~~~~~~~~~~~~~~~~
;   21 Feb 97   DJW   - First Version based on code supplied by Jonathan Hudson.
;

        .text
        .even

        .globl      __wm_rptrt

WM_RPTRT equ        $78

SAVEREG equ     12+4                ; size of saved registers + return address

;   Register usage:
;           IN                  OUT
;   d0                          Error code
;   d2.b    SMS event mask      preserved
;   d3.w    timeout             preserved
;   a0                          Channel Id of window
;   a4      working def

__wm_rptrt:
        movem.l d2/d3/a4,-(sp)      ; Save registers that can get corrupted
        move.l  SAVEREG+0(sp),a4    ; Working definition
        move.w  SAVEREG+4,d3        ; Timeout
        move.w  SAVEREG+6,d2        ; event
        moveq   #WM_RPTRT,d0        ; vector wanted
        move.l  d0,a0               ; ... and save in A0
        jsr     __wm_chkv           ; Check we know WMAN vector 
        bmi     finish              ; ... NO, exit immediately
        jsr     0(a0,d0.l)          ; ... YES, call vector
        tst.l   d0                  ; error occurred ?
        bmi     finish              ; ... YES, exit immediately
        move.l  a0,d0               ; ... NO, set reply to channel Id.
finish:
        movem.l (sp)+,d2/d3/a4      ; restore saved registers
        rts

