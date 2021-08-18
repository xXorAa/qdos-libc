;
;   u t _ m i n t
;
; Converts a short integer to ASCII and sends it to a channel
; equivalent to C routine
;   int     ut_mint (chanid_t channel, short value)
;                               8           c
; AMENDMENT HISTORY
; ~~~~~~~~~~~~~~~~~
;   10 Jul 93   DJW   - Removed setting of _oserr - merely return the
;                       QDOS error code
;                     - Removed use of link/ulnk by making parameter
;                       access relative to a7
;
;   06 Nov 93   DJW   - Added underscore to entry point name
;                     - Added SMS entry point name
;
;   24 Jan 94   DJW   - Added (yet another) underscore to entry point names
;                       for name hiding purposes

    .text
    .even
    .globl __ut_mint
    .globl __ut_wint

__ut_mint:
__ut_wint:
    movem.l d2-d3/a2-a3,-(a7)   ; save register variables
    move.l  4+16(a7),a0         ; channel
    move.w  10+16(a7),d1        ; value
    move.w  $ce,a2              ; vector required
    jsr     (a2)                ; ... and use it
    movem.l (a7)+,d2-d3/a2-a3   ; restore register variables
    rts

