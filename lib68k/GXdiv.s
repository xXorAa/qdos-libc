#
! c68 Support routine
! ~~~~~~~~~~~~~~~~~~~
! quotient and remainder of long quantities
!
! Amendement History
! ~~~~~~~~~~~~~~~~~~
! #1	Written from Xdiv.s				Thierry Godefroy

#include "68kconf.h"

#ifdef GCC_MATH

	SECTION TEXT
	SECTION ROM
	SECTION DATA
	SECTION BSS
!
! Export: .GXldiv,  .GXlrem,	.GXasldiv,  .GXaslrem
!	  .GXuldiv, .GXulrem, .GXasuldiv, .GXasulrem
!
	SECTION TEXT

!	Calculate remainder/result of dividing two longs

	XDEF	.GXlrem
.GXlrem:
	moveq	#1,d2			! Rest gewuenscht: Flag <> 0
	bra	Gdo_divs
!
	XDEF	.GXldiv
.GXldiv:
	moveq	#0,d2			! Quotient gewuenscht: Flag =0

!	Code common to divide/remainder of signed quantities

Gdo_divs:
	tst.l	4(a7)			! Dividend
	bge	_G1			! positive ? - YES, jump
	neg.l	4(a7)			! NO - negate dividend
	bchg	#31,d2			! invert D2 sign bit
_G1:
	tst.l	8(a7)			! Divisor
	beq	Gzerodiv 		! Divisor == 0
	bge	_G3			! Divisor positive ? - YES jump
	neg.l	8(a7)			! NO - negate divisor
	bchg	#31,d2			! toggle D2 sign bit
_G3:
!
!  both Operands now have positive sign
!
	bsr	Gshared			! call shared code to do calculation
	tst.w	d2			! remainder wanted?
	bne	_G10 			! ... yes, go and handle it then
!
! Quotient required
!
	tst.l	d2			! Quotient negative? (Rest immer positiv)
	bmi	Gnegate_answer
	rts
_G10:

!	Remainder required
!	N.B.	Answer must have same sign as dividend as we use
!			a round towards zero strategy for division
!
	tst.l	4(a7)			! Check sign of Dividend
	bmi	Gnegate_answer
	rts

Gnegate_answer:
	neg.l	d0			! ... else negate answer
	rts

!
!	Calculate remainder/result of dividing two unsigned longs
!
	XDEF	.GXulrem
.GXulrem:
	moveq	#1,d2			! Remainder is result: Flag <> 0
	bsr	Gshared
	rts

	XDEF	.GXuldiv
.GXuldiv:
	moveq	#0,d2			! Quotient is result: Flag =0
	bsr	Gshared
	rts

!
!	Shared code for signed/unsigned modes
!
Gshared:
	move.l	d6,a0			! save data registers that are corrupted
	move.l	d7,a1			! ... in unused address registers
	moveq	#0,d0			! Quotient set to 0
	move.l	4+4(a7),d7		! Dividend
	move.l	8+4(a7),d6		! Divisor
	bne 	Gnotzero 		! Divisor <> 0
Gzerodiv:
	divs	#0,d0			! EXCEPTION
	move.l	a0,d6			! restore data registers that are corrupted
	move.l	a1,d7			! ... from unused address registers
	addq.l	#4,sp			! remove return address
	rts
Gnotzero:
	cmp.l	d7,d6
	bcs	_G4			! Dividend > Divisor
	beq	_G5			! Dividend = Divisor
!
!  Dividend < Divisor: Quotient=0, Rest=Divisor
!
	bra	Gfinish
!
!  Special case of values being equal
!
_G5:
	move.l	#1,d0			! Quotient=1
	move.l	#0,d7			! Rest=0
	bra	Gfinish
!
_G4:
	cmp.l	#0x10000,d7
	bcc	_G6			! Dividend > 65536
!
! divu muss gelingen
!
	divu	d6,d7
	move.w	d7,d0
	clr.w	d7
	swap	d7
	bra	Gfinish
!
! Jetzt muss es doch brutal gemacht werden
!
_G6:
	moveq	#1,d1
_G7:
	cmp.l	d6,d7
	bcs	_G8
	tst.l	d6			! value is greater than 2^31 (only happens in unsigned cases)
	bmi	_G8			! ... YES, we better exit the loop then
!
! kein Check, ob das Bit schon draussen ist (wie bei udiv), da die
! Operanden kleiner als 2^31 sind
!
	asl.l	#1,d6
	asl.l	#1,d1
	bra	_G7
!
_G8:
	tst.l	d1
	beq	Gfinish
	cmp.l	d6,d7
	bcs	_G9
	or.l	d1,d0
	sub.l	d6,d7
_G9:
	lsr.l	#1,d1
	lsr.l	#1,d6
	bra	_G8

Gfinish:
!
! Quotient in d0, Rest in d7
!
	tst.w	d2			! Remainder wanted?
	beq	Gfinish2 		! No, then leave immediately
	move.l	d7,d0			! move Remainder to result register
Gfinish2:
	move.l	a0,d6			! restore data registers that are corrupted
	move.l	a1,d7			! ... from unused address registers
	rts

!
!	The following routines are the assign versions of the routines
!
	XDEF	.GXasldiv
.GXasldiv:
	lea	.GXldiv(pc),a1
	bra	Gdo_asl			! now join shared code

	XDEF	.GXaslrem
.GXaslrem:
	lea	.GXlrem(pc),a1
	bra	Gdo_asl

	XDEF	.GXasuldiv
.GXasuldiv:
	lea	.GXuldiv(pc),a1
	bra 	Gdo_asl

	XDEF	.GXasulrem
.GXasulrem:
	lea	.GXulrem(pc),a1

!	Code common to all the assign variants

Gdo_asl:
	move.l	4+4+0(sp),-(sp) 	! copy across original second parameter
	move.l	0+4+4(sp),a0		! get original first parameter
	move.l	(a0),-(sp)		! ... and store its target as new param
	jsr	(a1)			! go and execute required routine
	addq.l	#8,sp			! tidy up the stack
	move.l	0+4+0(sp),a0		! get original first param
	move.l	d0,(a0) 		! ... and store result at its target
	rts				! exit

#endif /* GCC_MATH */

	END
