;
;   u t _ u n l n k
;
; Unlink an item from a linked list
; equivalent to C routine
;   void  ut_unlnk (char *previtem, char * olditem)
;
; AMENDMENT HISTORY
; ~~~~~~~~~~~~~~~~~
;   06 Nov 93   DJW   - Added underscore to entry point name
;                     - Added SMS entry point name
;
;   24 Jan 94   DJW   - Added (yet another) underscore to entry point names
;                       for name hiding purposes

    .text
    .even
    .globl __ut_unlnk
    .globl __mem_rlst

__ut_unlnk:
__mem_rlst:
    move.l  a2,-(a7)            ; save register variable
    move.l  8(a7),a1            ; previous item
    move.l  12(a7),a0           ; old item
    move.w  $d4,a2              ; vector required
    jsr     (a2)                ; ... and use it
    move.l  (a7)+,a2            ; restore register variable
    rts


