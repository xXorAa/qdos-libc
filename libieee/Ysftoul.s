#
* C68 floating point => 32 bit unsigned conversion routines
*-----------------------------------------------------------------------------
* ported to 68000 by Kai-Uwe Bloem, 12/89
*	#1	original author: Peter S. Housel 6/12/89,6/14/89
*	#2	replaced shifts by swap if possible for speed increase -kub-, 01/90
*	#3	Added wrapper routine to provide C68 IEEE support
*											   Dave & Keith Walker	   02/92
*	#4	Changed entry/exit code for C68 v4.3 compatibility
*		Removed ACk entry points										09/93
*	#5	Changed to new parameter formats						-djw-	01/96
*	#6	Changed to allow directive types to be set				-djw-	02/97
*-----------------------------------------------------------------------------

#include "ieeeconf.h"

	   SECTION text

	   XDEF    .Ysftoul

*----------------------------------------
*	   sp	   Return address
*	   sp+4    float to convert
*----------------------------------------
.Ysftoul:
	move.w	4(sp),d0		! extract exp
	move.w	d0,d2			! extract sign
	lsr.w	#7,d0			! shift down 7
	and.w	#0x0ff,d0		! kill sign bit

	cmp.w	#BIAS4,d0		! check exponent
	blt	zer4 			! strictly fractional, no integer part ?
	cmp.w	#BIAS4+32,d0		! is it too big to fit in a 32-bit integer ?
	bgt	toobig

	move.l	4(sp),d1
	and.l	#0x7fffff,d1		! remove exponent from mantissa
	bset	#23,d1			! restore implied leading "1"

	sub.w	#BIAS4+24,d0		! adjust exponent
	bgt	2f			! shift up
	beq	3f			! no shift

	cmp.w	#-8,d0			! replace far shifts by swap
	bgt	1f
	clr.w	d1			! shift fast, 16 bits
	swap	d1
	add.w	#16,d0			! account for swap
	bgt	2f
	beq	3f

1:	lsr.l	#1,d1			! shift down to align radix point;
	addq.w	#1,d0			! extra bits fall off the end (no rounding)
	blt	1b			! shifted all the way down yet ?
	bra	3f

2:	add.l	d1,d1			! shift up to align radix point
	subq.w	#1,d0
	bgt	2b
	bra	3f
zer4:
	moveq	#0,d1			! make the whole thing zero
3:	move.l	d1,d0
	tst.w	d2			! is it negative ?
	bpl	8f
	neg.l	d0			! negate

8:	move.l	(sp)+,a0		! get return address
	addq.l	#4,sp			! tidy stack ( 1 x float )
	jmp	(a0)			! return to caller

toobig:
	jsr	.overflow
	moveq	#-1,d0			! set ULONG_MAX (-1=0xffffffff) as reply
	bra	8b

#ifdef GCC_MATH_FULL

	XDEF	.GYsftoul

*----------------------------------------
*	   sp	   Return address
*	   sp+4    float to convert
*----------------------------------------
.GYsftoul:
	move.w	4(sp),d0		! extract exp
	move.w	d0,d2			! extract sign
	lsr.w	#7,d0			! shift down 7
	and.w	#0x0ff,d0		! kill sign bit

	cmp.w	#BIAS4,d0		! check exponent
	blt	Gzer4			! strictly fractional, no integer part ?
	cmp.w	#BIAS4+32,d0		! is it too big to fit in a 32-bit integer ?
	bgt	Gtoobig

	move.l	4(sp),d1
	and.l	#0x7fffff,d1		! remove exponent from mantissa
	bset	#23,d1			! restore implied leading "1"

	sub.w	#BIAS4+24,d0		! adjust exponent
	bgt	G2			! shift up
	beq	G3			! no shift

	cmp.w	#-8,d0			! replace far shifts by swap
	bgt	G1
	clr.w	d1			! shift fast, 16 bits
	swap	d1
	add.w	#16,d0			! account for swap
	bgt	G2
	beq	G3

G1:	lsr.l	#1,d1			! shift down to align radix point;
	addq.w	#1,d0			! extra bits fall off the end (no rounding)
	blt	G1			! shifted all the way down yet ?
	bra	G3

G2:	add.l	d1,d1			! shift up to align radix point
	subq.w	#1,d0
	bgt	G2
	bra	G3
Gzer4:
	moveq	#0,d1			! make the whole thing zero
G3:	move.l	d1,d0
	tst.w	d2			! is it negative ?
	bpl	G8
	neg.l	d0			! negate

G8:	rts

Gtoobig:
	jsr	.overflow
	moveq	#-1,d0			! set ULONG_MAX (-1=0xffffffff) as reply
	rts

#endif /* GCC_MATH */

	END
