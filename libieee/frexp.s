#
* Remove exponent from 8 byte IEEE format floating point number
*-----------------------------------------------------------------------------
* ported to 68000 by Kai-Uwe Bloem, 12/89
*  #1  original author: Peter S. Housel 9/21/88,01/17/89,03/19/89,5/24/89
*  #2  added support for denormalized numbers				   -kub-, 01/90
*  #3  added code to allow for different sizeof(int) values
*	   by using limits.h
*	   Added NaN and infinity error cases.					   -djw- 09/93
*  #4  added code to handle negative numbers correctly		   -djw- 08/94
*  #5  Changes to support macroized assembler directives	   -djw-   02/97
*-----------------------------------------------------------------------------
*
*  double frexp (double x, int * nptr)
*
*  The function |frexp()| splits a floating point number into fraction |f| and
*  an exponent |n|, such that the absolute value of |f| is less than 1.0 but
*  not less than 0.5, and such that |f| times 2 raised to the power |n| is
*  equal to |x|.  The fraction |f| is returned and as a side effect the
*  exponent |n| is stored into the place pointed to by |nptr|.	If the
*  argument to |frexp()| is zero then both returned values will be zero.
*
*  If value is NaN, NaN is returned and errno may be set to EDOM.
*
*  If value is an infinity, an implementation defined value is returned, and
*  errno set to EDOM
*-----------------------------------------------------------------------------

#include "ieeeconf.h"

	SECTION text

	XDEF	_frexp

	XREF	_errno


#include <limits.h>
#if (SHRT_MAX == INT_MAX)
#define MOVE_ move.w
#define CLR_ clr.w
#define CMP_ cmp.w
#define ADD_ add.w
#define SUB_ sub.w
#define AND_ and.w
#else
#define MOVE_ move.l
#define CLR_ clr.l
#define CMP_ cmp.l
#define ADD_ add.l
#define SUB_ sub.l
#define AND_ and.l
#endif

_frexp:
	move.l	12(sp),a0		! initialize exponent for loop
#if (SHRT_MAX != INT_MAX)
	moveq	#0,d0			! ensure d0 is clear
#endif
	CLR_	(a0)
2:
	lea	4(sp),a1
	cmp.l	#0x7ff00000,(a1)	! Test first part for just max exponent set
	bne	5f
	tst.l	4(a1)			! Test second part is all zeroes
	beq	infinity
5:	move.w	(a1),d0 		! extract value.exp
	move.w	d0,d2			! save sign bit
	AND_	#0x8000,d2		! kill all but sign bit
	lsr.w	#4,d0
	AND_	#0x7ff,d0		! kill sign bit

	cmp.w	#0x7ff,d0		! NaN ?
	beq	NaNval

	CMP_	#BIAS8,d0		! get out of loop if finally (a1) in [0.5,1.0)
	beq	3f

	and.w	#0x0f,(a1)		! remove exponent from value.mantissa
	tst.w	d0			! check for zero exponent - no leading "1"
	beq	0f
	or.w	#0x10,(a1)		! restore implied leading "1"
	bra	1f
0:	ADD_	#1,d0
1:
	move.l	(a1),d1 		! check for zero
	or.l	4(a1),d1
	beq	3f			! if zero, all done : exp = 0, num = 0.0

	SUB_	#BIAS8,d0		! remove bias
	move.l	8(a1),a0		! add current exponent in
	ADD_	d0,(a0)

	MOVE_	#BIAS8,d0		! set bias for return value
	clr.w	d1			! rounding = 0
	jsr	.Xnorm8 		! normalize result
	bra	2b			! loop around to catch denormalized numbers
3:
	movem.l	4(sp),d0-d1		! return normalized mantissa
	rts

NaNval:
infinity:
	MOVE_	#EDOM,_errno		! set errno
	movem.l	(a1),d0-d1		! copy across input as reply
	rts

	END
