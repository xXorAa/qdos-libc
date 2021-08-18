;
;   u t _ w i n d
;
; simplified routine to open a window using defined name.
; equivlent to c routine
;
;   chanid_t ut_windowf( char * name, char *params)
;                             8           c
; AMENDMENT HISTORY
; ~~~~~~~~~~~~~~~~~
;   10 Jul 93   DJW     Removed use of _oserr - merely returns the 
;                       QDOS error code on failure.
;
;   06 Nov 93   DJW   - Added underscore to entry point name
;                     - Added SMS entry point name
;
;   24 Jan 94   DJW   - Added (yet another) underscore to entry point names
;                       for name hiding purposes
;
;   03 Sep 94   DJW   - Added underscore to _cstr_to_ql for name hiding reasons

    .text
    .even
    .globl __ut_window
    .globl __opw_wind

__ut_window:
__opw_wind:
    link    a6,#-128
    movem.l d2-d3/a2-a3,-(a7)   ; save register variables
    move.l  8(a6),-(a7)         ; name
    pea.l   -128(a6)            ; address for result
    jsr     __cstr_to_ql        ; convert to qlstr
    addq.l  #8,a7               ; restore stack
    move.l  d0,a0               ; qlstr
    move.l  $c(a6),a1           ; parameter block
    move.w  #$C4,a2             ; vector number
    jsr     (a2)                ; call it
    tst.l   d0                  ; OK ?
    bne     fin                 ; ... and jump if error
    move.l  a0,d0               ; move channel to return code
fin:
    movem.l (a7)+,d2-d3/a2-a3   ; restore register variables
    unlk    a6
    rts

