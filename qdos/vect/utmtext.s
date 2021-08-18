;
;   u t _ m t e x t
;
; sends a message to a channel
; equivalent to C routine
;   int     ut_mtext (chanid_t channel, char * message)
;                               8           c
;
; AMENDMENT HISTORY
; ~~~~~~~~~~~~~~~~~
;   10 Jul 93   DJW   - Removed useage of _oserr - merely returns the
;                       QDOS error code
;                     - Removed link/ulnk by making parameter access
;                       relative to a7
;
;   06 Nov 93   DJW   - Added underscore to entry point name
;                     - Added SMS entry point name
;
;   24 Jan 94   DJW   - Added (yet another) underscore to entry point names
;                       for name hiding purposes.
;
;   19 Sep 94   DJW   - Found that entry point name was incorrect for
;                       the SMS case.  Changed to correct value.

    .text
    .even
    .globl __ut_mtext
    .globl __ut_wtext

__ut_mtext:
__ut_wtext:
    movem.l d2-d3/a2-a3,-(a7)   ; save register variables
    move.l  4+16(a7),a0         ; channel
    move.l  8+16(a7),a1         ; message
    move.w  $d0,a2              ; vector required
    jsr     (a2)                ; ... and use it
    movem.l (a7)+,d2-d3/a2-a3   ; restore register variables
    rts

