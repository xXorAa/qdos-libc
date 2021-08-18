#
 !
 !              s t r t o d _ a u x
 !
 ! auxiliary routines for strtod()
 !-----------------------------------------------------------------------------
 ! ported to 68000 by Kai-Uwe Bloem, 12/89
 !  #1  original author: Peter S. Housel 6/3/89
 !  #2  ported to QDOS for C68 IEEE version         D.J.Walker  05/92
 !  #3  corrected sizeof(int) problem               D.J.Walker  06/92
 !  #4  corrected further problems with 32bit ints  D.J.Walker  03/95
 !-----------------------------------------------------------------------------
/*
 *  The assembler routines that are in this file are equivalent to the
 *  following C routines:
 *
 *  int     _mul10add  _PROTOTYPE((double *valuep, int digit));
 *  double  _adjust    _PROTOTYPE((double *valuep, int decexp, int negflag));
 */

    .globl  __mul10add
    .globl  __adjust

#if (TARGET == M68000)

#include <limits.h>

#if (INT_MAX == SHRT_MAX)
#define MOVE_ move.w
#define ADD_ add.w
#define SUB_ sub.w
#define TST_ tst.w
#define LEN 2
#else
#define MOVE_ move.l
#define ADD_ add.l
#define SUB_ sub.l
#define TST_ tst.l
#define LEN 4
#endif


BIAS8   =   0x3FF - 1

    .sect .text
__mul10add:
    move.l  4(sp),a1
    MOVE_   8(sp),a0
    movem.l d3-d5,-(sp)

    MOVE_   #1,d0               ! return 1 on overflow
    move.w  (a1),d1
    cmp.w   #3276,d1            ! would this digit cause overflow ?
    bgt     1f

    movem.l (a1),d4-d5

    add.l   d5,d5               ! multiply accumulator by 10 - first
    addx.l  d4,d4               !  we multiply by two

    move.l  d4,d2               ! save 2x value
    move.l  d5,d3

    add.l   d5,d5               ! multiply by 4, to make this
    addx.l  d4,d4               !  8x the original accumulator
    add.l   d5,d5
    addx.l  d4,d4

    add.l   d3,d5               ! add 2x value back in
    addx.l  d2,d4

    clr.l   d0                  ! return zero overflow flag
#if (INT_MAX == SHRT_MAX)
    move.l  #0,d1              ! get digit value
#endif
    MOVE_   a0,d1
    add.l   d1,d5               ! add it in
    addx.l  d0,d4

    movem.l d4-d5,(a1)

1:  movem.l (sp)+,d3-d5
    rts

__adjust:
    move.l  4(sp),a1            ! a1 => 64-bit accumulator
    tst.l   4(a1)               ! last part zero ?
    bne     0f                  ! ... no continue
    tst.l   4(a1)               ! first part zero
    bne     0f                  ! ... no continue
    rts                         ! YES - return 0

0:
    lea     8(sp),a0            ! exponent address
    movem.l d3-d5,-(sp)
    movem.l (a1),d4-d5

    MOVE_   (a0),d1             ! d1 = decimal exponent
    MOVE_   #0,d0               ! d0 = binary scale factor
    TST_    d1                  ! check decimal exponent
    beq     9f                  ! if zero, no scaling neccessary
    bmi     4f                  ! if negative, do division loop
1:
    cmp.l   #0x019998000,d4     ! compare with 2^15/5 in most sig word
    bls     2f                  ! no danger of overflow ?
    lsr.l   #1,d4               ! could overflow; divide by two
    roxr.l  #1,d5               !  to prevent it
    ADD_    #1,d0               ! increment scale factor to compensate
    bra     1b                  ! try again to see if we are ok now
2:
    move.l  d4,d2               ! now we multiply by 5
    move.l  d5,d3               !  save 1x value

    add.l   d5,d5               ! multiply by four,
    addx.l  d4,d4
    add.l   d5,d5
    addx.l  d4,d4

    add.l   d3,d5               ! add 1x value back in
    addx.l  d2,d4

    ADD_    #1,d0               ! increment scale factor to make this
                                !  a multiplication by 10
    SUB_    #1,d1               ! decrement decimal exponent
    bne     1b                  ! keep scaling if not done

    bra     9f                  ! done with multiplication loop
4:
    move.l  d4,d2               ! make sure upper bits set to preserve
    and.l   #0xC0000000,d2      !  as much precision as possible
    bne     5f
    add.l   d5,d5               ! if not, multiply by 2
    addx.l  d4,d4
    SUB_    #1,d0               ! decrement scale factor to compensate
    bra     4b                  ! and check again

5:                              ! division by 5
    clr.l   d2                  ! start off with zero remainder

    swap    d4
    move.w  d4,d2
    divu    #5,d2               ! d2.lo = result, d2.hi = remainder
    move.w  d2,d3               ! store result
    swap    d3

    swap    d4
    move.w  d4,d2
    divu    #5,d2
    move.w  d2,d3
    move.l  d3,d4

    swap    d5
    move.w  d5,d2
    divu    #5,d2
    move.w  d2,d3
    swap    d3

    swap    d5
    move.w  d5,d2
    divu    #5,d2
    move.w  d2,d3
    move.l  d3,d5

    SUB_    #1,d0               ! decrement scale factor to make this
                                !  a division by 10
    ADD_    #1,d1               ! increment decimal exponent
    bne     4b                  ! keep looking if not done
9:
    movem.l d4-d5,(a1)          ! just to be safe ...
    MOVE_   d0,-(sp)            ! scale factor; multiplier for ldexp()
    movem.l d4-d5,-(sp)         ! copy value onto stack

    move.l  sp,a1               ! address for norm8
    TST_    LEN(a0)             ! set sign
    sne     d2
    ext.w   d2
    clr.b   d1                  ! rounding bits = 0
    move.w  #BIAS8+53,d0        ! first normalize the number as
    jsr     .Xnorm8             !  an integer,
    jsr     _ldexp              ! then re-scale it using ldexp()
                                !  to check for over/underflow
    add.w   #8+LEN,sp           ! remove args

    movem.l (sp)+,d3-d5
    rts

#endif /* M68000 */

