#
* C68: split 'float' number into integer and fractional pieces
*-----------------------------------------------------------------------------
*  #1  Based on C68 modf() routine				   Dave Walker		   10/93
*  #2  Corrected problem with using 'bls' instead of 'blt'		-djw-  08/94
*  #3  Changes to support macroized assembler directives	   -djw-   02/97
*-----------------------------------------------------------------------------
*  float modff (float x, float * nptr)
*
*  The function |modff()| splits a single precision floating point number
*  into a fractional part |f| and an integer part |n|, such that the
*  absolute value of |f| is less than 1.0 and such that |f| plus |n| is
*  equal to |x|.  Both |f| and |n| will have the same sign as the input
*  argument.  The fractional part |f| is returned, and as a side effect
*  the integer part |n| is stored into the place pointed to by |nptr|.
*
*  If |x| is a NaN, then errno is set to EDOM, and a NaN returned.
*-----------------------------------------------------------------------------

#include "ieeeconf.h"

	SECTION text

	XDEF	_modff

	XREF	_errno


#include <limits.h>
#if (INT_MAX == SHRT_MAX)
#define MOVE_ move.w
#else
#define MOVE_ move.l
#endif

_modff:
	lea	4(sp),a0		! a0 -> float argument
	move.l	8(sp),a1		! a1 -> ipart result

	move.w	(a0),d0 		! extract value.exp
	move.w	d0,d2			! extract value.sign
	lsr.w	#7,d0
	and.w	#0xff,d0		! kill sign bit

	cmp.w	#0xff,d0		! NaN ?
	beq	NaNval			! ... YES, then errore exit

	cmp.w	#BIAS4,d0
	bge	1f			! fabs(value) >= 1.0

	clr.l	(a1)			! store zero as the integer part
retval:
	move.l	(a0),d0			! return entire value as fractional part
	rts
NaNval:
	MOVE_	#EDOM,_errno		! set errno value
	bra	retval			! exit returning original NaN value

1:
	cmp.w	#BIAS4+24,d0		! all integer, with no fractional part ?
	blt	2f			! no, mixed

	move.l	(a0),(a1)		! store entire value as the integer part
	moveq	#0,d0			! return zero as fractional part
	rts
2:
	movem.l	d4/d6,-(sp)		! save some registers
	move.l	(a0),d4			! get value

	and.l	#0x7fffff,d4		! remove exponent from value.mantissa
	bset	#23,d4			! restore implied leading "1"

	moveq	#0,d6			! zero fractional part
3:
	cmp.w	#BIAS4+8,d0		! fast shift, 16 bits ?
	bgt	5f
	clr.w	d6			! shift down 16 bits
	move.w	d4,d6
	clr.w	d4
	swap	d6
	swap	d4
	add.w	#16,d0
	bra	3b
4:
	lsr.l	#1,d4			! shift integer part
	roxr.l	#1,d6			! shift high bit into fractional part

	addq.w	#1,d0			! increment ipart exponent
5:
	cmp.w	#BIAS4+24,d0		! done ?
	blt	4b			! keep shifting
	move.l	d4,(a1)			! save ipart
	move.l	d6,(a0)			! save frac part
	movem.l	(sp)+,d4/d6		! get registers back

	movem.l	d2/a0,-(sp)		! save address and sign of frac part
	clr.w	d1			! clear rounding bits
	jsr	.Xnorm4 		! renormalize integer part

	movem.l	(sp)+,d2/a1		! get address and sign back
	clr.w	d1			! clear rounding bits
	move.w	#BIAS4-8,d0		! set frac part exponent
	jsr	.Xnorm4 		! renormalize fractional part

	move.l	4(sp),d0		! return fract part
	rts

	END
