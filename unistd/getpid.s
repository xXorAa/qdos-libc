;   g e t p i d
;
; routine to get job id
; Equvialent to C routine:
;
;   jobid_t getpid (void)
;
; AMENDMENT HISTORY
; ~~~~~~~~~~~~~~~~~
;   07 Nov 93   DJW   - Added underscore to entry point
;
;   16 Nov 93   DJW   - Changed to using a5 instead of a6 for link
;
;   08 Sep 94   DJW   - Changed to simply return value of global variable
;                       '_jobid' that is set up in startup code.
;
;   12 Nov 95   DJW   - Added the setpgrp() entry point.

    .text
    .even
    .globl _getpid
    .globl _setpgrp

_getpid:
_setpgrp:
    move.l  __Jobid,d0
    rts

