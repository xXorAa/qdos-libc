#
* C68 4 byte floating point => 32 bit integer conversion routines
*-----------------------------------------------------------------------------
* ported to 68000 by Kai-Uwe Bloem, 12/89
*  #1	Written from Ysftol.s				Thierry Godefroy
*-----------------------------------------------------------------------------

#include "ieeeconf.h"

#ifdef GCC_MATH

	SECTION text

	XDEF	.GYsftol

*----------------------------------------
*	   sp	   Return address
*	   sp+4    float to convert
*----------------------------------------
.GYsftol:
	move.w	4(sp),d0			! extract exp
	move.w	d0,d2				! extract sign
	lsr.w	#7,d0				! shift down 7
	and.w	#0x0ff,d0			! kill sign bit

	cmp.w	#BIAS4,d0			! check exponent
	blt	Gzer4				! strictly fractional, no integer part ?
	cmp.w	#BIAS4+32,d0			! is it too big to fit in a 32-bit integer ?
	bgt	Gtoobig

	move.l	4(sp),d1			! will be used later
	and.l	#0x7fffff,d1			! remove exponent from mantissa
	bset	#23,d1				! restore implied leading "1"

	sub.w	#BIAS4+24,d0			! adjust exponent
	bgt	G2				! shift up
	beq	G3				! no shift

	cmp.w	#-8,d0				! replace far shifts by swap
	bgt	G1
	clr.w	d1				! shift fast, 16 bits
	swap	d1
	add.w	#16,d0				! account for swap
	bgt	G2
	beq	G3

G1:	lsr.l	#1,d1				! shift down to align radix point;
	addq.w	#1,d0				! extra bits fall off the end (no rounding)
	blt	G1				! shifted all the way down yet ?
	bra	G3

G2:	add.l	d1,d1				! shift up to align radix point
	subq.w	#1,d0
	bgt	G2
	bra	G3
Gzer4:
	moveq	#0,d1				! make the whole thing zero

G3:	move.l	d1,d0				! put integer into register
	cmp.l	#0x80000000,d0			! -2147483648 is a nasty evil special case
	bne	G6
	tst.w	d2				! this had better be -2^31 and not 2^31
	bpl	Gtoobig
	bra	Gfin
G6:	tst.l	d0				! sign bit set ? (i.e. too big)
	bmi	Gtoobig
	tst.w	d2				! is it negative ?
	bpl	Gfin
	neg.l	d0				! negate
Gfin:
	rts

Gtoobig:
	jsr	.overflow			! Default overflow handling routine
	jsr	.setmaxmin			! If control returned, set LONG_MAX/LONG_MIN
	rts

#endif /* GCC_MATH */

	END
