#
;   Routines to provide the C68 setjmp() and longjmp() functions
;
;   AMENDMENT HISTORY
;   ~~~~~~~~~~~~~~~~~
;   10 Jan 93   DJW     Amended to correctly take into account the
;                       sizeof(int) by looking at the limits.h header
;                       file (problem reported by Richard Zidlicky)
;
;   07 Nov 93   DJW   - Added underscore to entry point
;
;   20 Dec 93   DJW   - Corrected problem in longjmp() whereby d0 was not
;                       being set correctly.

#include <limits.h>

#if (INT_MAX == SHRT_MAX)
#define MOVE_ move.w
#else
#define MOVE_ move.l
#endif

    .text
    .even
    .globl _setjmp
    .globl _longjmp

_setjmp:
    move.l  4(sp),a0        ; address of jmp_buf[]
    move.l  a7,(a0)+        ; save stack pointer
    move.l  a6,(a0)+        ; save frame pointer
    move.l  (a7),(a0)+      ; save return address
    movem.l d2-d7/a2-a5,(a0); save registers
    moveq   #0,d0           ; return value is 0
    rts

_longjmp:
    move.l  4(sp),a0        ; address of jmp_buf[]
    MOVE_   8(sp),d0        ; value to return
    bne     nonzero
    moveq   #1,d0           ; make it non-zero
nonzero:
    move.l  (a0)+,a7        ; restore stack pointer
    move.l  (a0)+,a6        ; restore frame pointer
    move.l  (a0)+,(sp)      ; restore return address
    movem.l (a0),d2-d7/a2-a5; restore registers
    rts

