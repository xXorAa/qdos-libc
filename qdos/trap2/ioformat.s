;
;   i o _ f o r m a t / i o a _ f r m t
;
; routine to format a medium.
; equivalent to c routine
;   int io_format( char *device, int *totsecs, int *goodsecs)
;
; AMENDMENT HISTORY
; ~~~~~~~~~~~~~~~~~
;   10 Jul 93   DJW     Removed setting of _oserr.
;
;   24 Jul 93   DJW   - Added SMS entry point
;                     - Changed link/ulnk instructions to use a5
;                     - Used ext.l instructions to convert D1/D2 value to
;                       32 bits instead of previous method using 'swap'
;
;   06 Nov 93   DJW   - Added underscore to entry point names
;
;   24 Jan 94   DJW   - Added (yet another) underscore to entry point names
;                       for name hiding purposes

    .text
    .even
    .globl __io_format        ; QDOS name for call
    .globl __ioa_frmt         ; SMS name for call

WORKLEN equ 42          ; size of stack workspace
SAVEREG equ 4           ; size of saved registers

__io_format:
__ioa_frmt:
    link    a5,#-WORKLEN        ; create workspace on stack
    move.l  d2,-(a7)            ; save register variables
    move.l  4+4(a5),-(a7)       ; push name
    pea.l   -WORKLEN(a5)        ; qlstr
    jsr     __cstr_to_ql        ; convert
    addq.l  #8,a7               ; tidy up stack
    move.l  d0,a0               ; qlstr
    moveq.l #3,d0
    trap    #2
    move.l  12+4(a5),a0
    move.w  d1,(a0)             ; return good sectors
    move.l  8+4(a5),a0
    move.w  d2,(a0)             ; return total sectors
    move.l  (a7)+,d2            ; restore register variables
    unlk    a5                  ; remove stack workspace
    rts

