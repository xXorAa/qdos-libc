#
* C68 8 byte floating point => 32 bit integer conversion routines
*-----------------------------------------------------------------------------
*  #1  Written from Ydftol.s				Thierry Godefroy
*-----------------------------------------------------------------------------

#include "ieeeconf.h"

#ifdef GCC_MATH

	SECTION text

	XDEF	.GYdftol

*----------------------------------------
*	   sp	   Return address
*	   sp+4    double to convert
*----------------------------------------

.GYdftol:
	move.w	4(sp),d0		! extract exp
	move.w	d0,a1			! extract sign
	lsr.w	#4,d0
	and.w	#0x07ff,d0		! kill sign bit

	cmp.w	#BIAS8,d0		! check exponent
	blt	Gzer8			! strictly factional, no integer part ?
	cmp.w	#BIAS8+32,d0		! is it too big to fit in a 32-bit integer ?
	bgt	Gtoobig

	movem.l	4(sp),d1-d2		! get the value
	and.l	#0x0fffff,d1		! remove exponent from mantissa
	bset	#20,d1			! restore implied leading "1"

	sub.w	#BIAS8+21,d0		! adjust exponent
	bgt	Gshiftup		! shift up
	beq	G3			! no shift

	cmp.w	#-8,d0			! replace far shifts by swap
	bgt	G1
	move.w	d1,d2			! shift fast, 16 bits
	swap	d2
	clr.w	d1
	swap	d1
	add.w	#16,d0			! account for swap
	bgt	Gshiftup
	beq	G3

G1:	lsr.l	#1,d1			! shift down to align radix point;
	addq.w	#1,d0			! extra bits fall off the end (no rounding)
	blt	G1			! shifted all the way down yet ?
	bra	G3

Gshiftup:
	add.l	d2,d2			! shift up to align radix point
	addx.l	d1,d1
	subq.w	#1,d0
	bgt	Gshiftup
	bra	G3
Gzer8:
	moveq	#0,d1			! make the whole thing zero

G3:	move.l	d1,d0			! save significant 32 bits
	move.w	a1,d2			! get sign into d2

	cmp.l	#0x80000000,d0		! -2147483648 is a nasty evil special case
	bne	Gsignset
	tst.w	d2			! this had better be -2^31 and not 2^31
	bpl	Gtoobig
	rts

Gsignset:
	tst.l	d0			! sign bit set ? (i.e. too big)
	bmi	Gtoobig
	tst.w	d2			! is it negative ?
	bpl	G2
	neg.l   d0			! negate
G2:
	rts

Gtoobig:
	jsr 	.overflow		! Default overflow handling routine
	jsr 	.setmaxmin		! If control returned, set LONG_MAX/LONG_MIN
	rts

#endif /* GCC_MATH */

	END
