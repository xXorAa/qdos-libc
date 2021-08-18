;   FILE: stackreport_x
;
;   This file simply reports the margin between the actual stack,
;   and the bottom of the area allocated to it (as set by crt_o)
;   A negative value means trouble as you are overwriting data areas!
;
; AMENDMENT HISTORY
; ~~~~~~~~~~~~~~~~~
;
;   06 Nov 93   DJW   - Added underscore to entry point names

    .text
    .globl  _stackreport

_stackreport:
    move.l  a7,d0
    sub.l   __SPbase,d0
    rts
