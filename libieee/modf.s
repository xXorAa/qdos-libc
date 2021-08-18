#
* C68: split 'double' number into integer and fractional pieces
*-----------------------------------------------------------------------------
* ported to 68000 by Kai-Uwe Bloem, 12/89
*  #1  original author: Peter S. Housel 9/21/88,01/17/89,03/19/89,5/24/89
*  #2  replaced shifts by swap if possible for speed increase  -kub-, 01/90
*  #3  Added use of limits.h to allow for both 16 and 32 bit ints.
*	   Added check for NaN input							   -djw-  09/93
*  #4  Corrected problem with using SHORT_MAX isntead of SHRT_MAX
*	   Corrected problem with using 'bls' instead of 'blt'	   -djw-  12/93
*  #5  Changes to support macroized assembler directives	   -djw-   02/97
*-----------------------------------------------------------------------------
*  double modf (double x, double * nptr)
*
*  The function |modf()| splits a double precision floating point number
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

	XDEF	_modf

	XREF	_errno


#include <limits.h>
#if (INT_MAX == SHRT_MAX)
#define MOVE_ move.w
#else
#define MOVE_ move.l
#endif

_modf:
	lea 	4(sp),a0		! a0 -> double argument
	move.l	12(sp),a1		! a1 -> ipart result

	move.w	(a0),d0 		! extract value.exp
	move.w	d0,d2			! extract value.sign
	lsr.w	#4,d0
	and.w	#0x7ff,d0		! kill sign bit

	cmp.w	#0x7ff,d0		! NaN ?
	beq 	NaNval			! ... YES, then errore exit

	cmp.w	#BIAS8,d0
	bge 	1f			! fabs(value) >= 1.0

	clr.l	(a1)			! store zero as the integer part
	clr.l	4(a1)
retval:
	movem.l (a0),d0-d1		! return entire value as fractional part
	rts
NaNval:
	MOVE_	#EDOM,_errno		! set errno value
	bra 	retval			! exit returning original NaN value

1:
	cmp.w	#BIAS8+53,d0		! all integer, with no fractional part ?
	blt 	2f			! no, mixed

	move.l	(a0),(a1)		! store entire value as the integer part
	move.l	4(a0),4(a1)
	moveq	#0,d0			! return zero as fractional part
	moveq	#0,d1
	rts
2:
	movem.l d4-d7,-(sp)		! save some registers
	movem.l (a0),d4-d5		! get value

	and.l	#0x0fffff,d4		! remove exponent from value.mantissa
	bset	#20,d4			! restore implied leading "1"

	moveq	#0,d6			! zero fractional part
	moveq	#0,d7
3:
	cmp.w	#BIAS8+37,d0		! fast shift, 16 bits ?
	bgt 	5f
	move.w	d6,d7			! shift down 16 bits
	move.w	d5,d6
	move.w	d4,d5
	clr.w	d4
	swap	d7
	swap	d6
	swap	d5
	swap	d4
	add.w	#16,d0
	bra 	3b
4:
	lsr.l	#1,d4			! shift integer part
	roxr.l	#1,d5

	roxr.l	#1,d6			! shift high bit into fractional part
	roxr.l	#1,d7

	addq.w	#1,d0			! increment ipart exponent
5:
	cmp.w	#BIAS8+53,d0		! done ?
	blt 	4b				! keep shifting
	movem.l	d4-d5,(a1)		! save ipart
	movem.l	d6-d7,(a0)		! save frac part
	movem.l	(sp)+,d4-d7		! get registers back

	movem.l	d2/a0,-(sp)		! save address and sign of frac part
	clr.w	d1			! clear rounding bits
	jsr 	.Xnorm8 		! renormalize integer part

	movem.l (sp)+,d2/a1		! get address and sign back
	clr.w	d1			! clear rounding bits
	move.w	#BIAS8-11,d0		! set frac part exponent
	jsr 	.Xnorm8 		! renormalize fractional part

	movem.l	4(sp),d0-d1		! return fract part
	rts

	END
