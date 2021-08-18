#
* C68 12 byte floating point => 32 bit integer conversion routines
*-----------------------------------------------------------------------------
*  #1  First version.  Based on 8 bytes Ydftol_s.		 Dave Walker   01/96
*  #2  Changes to support macroized assembler directives	   -djw-   02/97
*-----------------------------------------------------------------------------

#include "ieeeconf.h"

#ifdef LONG_DOUBLE

	SECTION text

	XDEF	.Ylftol

*----------------------------------------
*	   sp	   Return address
*	   sp+4    long double to convert
*----------------------------------------
.Ylftol:
	move.w	4(sp),d1		! extract exp
	and.w	#0x7fff,d1		! kill sign bit

	sub.w	#BIAS12,d1		! check exponent
	bge 	0f			! OK if not just fractional
	moveq	#0,d0			! NO, set answer to zero
	bra 	finish			! ... and exit

0:	sub.w	#32,d1			! is exponent too big to fit in a 32-bit integer ?
	bgt 	toobig			! ... YES, set overflow condition

	neg.w	d1			! convert to shift size
	move.l	8(sp),d0		! load mantissa
	asr.l	d1,d0			! shift into position

	move.w	4(sp),d2		! get sign into d2
	cmp.l	#0x80000000,d0		! -2147483648 is a nasty evil special case
	bne 	6f
	tst.w	d2			! this had better be -2^31 and not 2^31
	bpl 	toobig
	bra 	finish
6:	tst.l	d0			! sign bit set ? (i.e. too big)
	bmi 	toobig
	tst.w	d2			! is it negative ?
	bpl 	finish
	neg.l	d0			! negate

finish:
	move.l	(sp)+,a1		! get return address
	lea 	12(sp),sp		! tidy stack ( 1 x long double)
	jmp 	(a1)

toobig:
	jsr 	.overflow		! Default overflow handling routine
	jsr 	.setmaxmin		! If control returned, set LONG_MAX/LONG_MIN
	bra 	finish			! .., and exit back to user

#ifdef GCC_MATH_FULL

	XDEF	.GYlftol

*----------------------------------------
*	   sp	   Return address
*	   sp+4    long double to convert
*----------------------------------------
.GYlftol:
	move.w	4(sp),d1		! extract exp
	and.w	#0x7fff,d1		! kill sign bit

	sub.w	#BIAS12,d1		! check exponent
	bge 	G0			! OK if not just fractional
	moveq	#0,d0			! NO, set answer to zero
	rts				! ... and exit

G0:	sub.w	#32,d1			! is exponent too big to fit in a 32-bit integer ?
	bgt 	Gtoobig			! ... YES, set overflow condition

	neg.w	d1			! convert to shift size
	move.l	8(sp),d0		! load mantissa
	asr.l	d1,d0			! shift into position

	move.w	4(sp),d2		! get sign into d2
	cmp.l	#0x80000000,d0		! -2147483648 is a nasty evil special case
	bne 	G6
	tst.w	d2			! this had better be -2^31 and not 2^31
	bpl 	Gtoobig
	rts
G6:	tst.l	d0			! sign bit set ? (i.e. too big)
	bmi 	Gtoobig
	tst.w	d2			! is it negative ?
	bpl 	Gfinish
	neg.l	d0			! negate
Gfinish:
	rts

Gtoobig:
	jsr 	.overflow		! Default overflow handling routine
	jsr 	.setmaxmin		! If control returned, set LONG_MAX/LONG_MIN
	rts

#endif /* GCC_MATH */

#endif /* LONG_DOUBLE */

	END
