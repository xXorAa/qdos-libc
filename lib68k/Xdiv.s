#
! c68 Support routine
! ~~~~~~~~~~~~~~~~~~~
! quotient and remainder of long quantities
!
! Amendement History
! ~~~~~~~~~~~~~~~~~~
! #1  10 Dec 92 Changed .lrem so that answer always has the
!		same sign as dividend (previously was always
!		giving a positive result)		Dave Walker
! #2  11 Dec 92 Changed exit code to tidy up stack. Dave Walker
! #3  18 Jul 94 Commoned up code for signed and unsigned
!		variants.  This also fixed a bug on the signed
!		divide for a value of -2^32 	Dave Walker
! #4  24 Aug 00 Managed to common up much more code between signed
!		and unsigned variants.			Dave Walker
! #5  18 Sep 00 Converted directives to macrosized versions Dave Walker
!

#include "68kconf.h"

	SECTION TEXT
	SECTION ROM
	SECTION DATA
	SECTION BSS
!
! Export: .Xldiv,  .Xlrem,	.Xasldiv,  .Xaslrem
!	  .Xuldiv, .Xulrem, .Xasuldiv, .Xasulrem
!
	SECTION TEXT

!	Calculate remainder/result of dividing two longs

	XDEF	.Xlrem
.Xlrem:
	moveq	#1,d2			! Rest gewuenscht: Flag <> 0
	bra	do_divs
!
	XDEF	.Xldiv
.Xldiv:
	moveq	#0,d2			! Quotient gewuenscht: Flag =0

!	Code common to divide/remainder of signed quantities

do_divs:
	tst.l	4(a7)			! Dividend
	bge	_1			! positive ? - YES, jump
	neg.l	4(a7)			! NO - negate dividend
	bchg	#31,d2			! invert D2 sign bit
_1:
	tst.l	8(a7)			! Divisor
	beq	zerodiv 		! Divisor == 0
	bge	_3			! Divisor positive ? - YES jump
	neg.l	8(a7)			! NO - negate divisor
	bchg	#31,d2			! toggle D2 sign bit
_3:
!
!  both Operands now have positive sign
!
	bsr	shared			! call shared code to do calculation
	tst.w	d2			! remainder wanted?
	bne	_10 			! ... yes, go and handle it then
!
! Quotient required
!
	tst.l	d2			! Quotient negative? (Rest immer positiv)
	bpl	tidyup
	bra	negate_answer
!
_10:
!
!	Remainder required
!	N.B.	Answer must have same sign as dividend as we use
!			a round towards zero strategy for division
!
	tst.l	4(a7)			! Check sign of Dividend
	bge	tidyup			! positive/zero merely exit
negate_answer:
	neg.l	d0			! ... else negate answer

!
!	Code common to all exit paths
!
tidyup:
	move.l	(sp)+,a0		! get return address
	addq.l 	#8,sp			! remove two long parameters
	jmp	(a0)			! return to calling code

!
!	Calculate remainder/result of dividing two unsigned longs
!
	XDEF	.Xulrem
.Xulrem:
	moveq	#1,d2			! Remainder is result: Flag <> 0
	bra	do_divu

	XDEF	.Xuldiv
.Xuldiv:
	moveq	#0,d2			! Quotient is result: Flag =0
!
!	Code common to unsigned dive/remainder
!
do_divu:
	bsr	shared			! call code common to all variants
	bra	tidyup			! ... and now leave

!
!	Shared code for signed/unsigned modes
!
shared:
	move.l	d6,a0			! save data registers that are corrupted
	move.l	d7,a1			! ... in unused address registers
	moveq	#0,d0			! Quotient set to 0
	move.l	4+4(a7),d7		! Dividend
	move.l	8+4(a7),d6		! Divisor
	bne	notzero 		! Divisor <> 0
zerodiv:
	divs	#0,d0			! EXCEPTION
	move.l	a0,d6			! restore data registers that are corrupted
	move.l	a1,d7			! ... from unused address registers
	addq.l	#4,sp			! remove return address
	bra	tidyup
notzero:
	cmp.l	d7,d6
	bcs	_4			! Dividend > Divisor
	beq	_5			! Dividend = Divisor
!
!  Dividend < Divisor: Quotient=0, Rest=Divisor
!
	bra finish
!
!  Special case of values being equal
!
_5:
	moveq	#1,d0			! Quotient=1
	moveq	#0,d7			! Rest=0
	bra	finish
!
_4:
	cmp.l	#0x10000,d7
	bcc	_6			! Dividend > 65536
!
! divu muss gelingen
!
	divu	d6,d7
	move.w	d7,d0
	clr.w	d7
	swap	d7
	bra	finish
!
! Jetzt muss es doch brutal gemacht werden
!
_6:
	moveq	#1,d1
_7:
	cmp.l	d6,d7
	bcs	_8
	tst.l	d6			! value is greater than 2^31 (only happens in unsigned cases)
	bmi	_8			! ... YES, we better exit the loop then
!
! kein Check, ob das Bit schon draussen ist (wie bei udiv), da die
! Operanden kleiner als 2^31 sind
!
	asl.l	#1,d6
	asl.l	#1,d1
	bra	_7
!
_8:
	tst.l	d1
	beq	finish
	cmp.l	d6,d7
	bcs	_9
	or.l	d1,d0
	sub.l	d6,d7
_9:
	lsr.l	#1,d1
	lsr.l	#1,d6
	bra	_8
!
finish:
!
! Quotient in d0, Rest in d7
!
	tst.w	d2			! Remainder wanted?
	beq 	finish2 		! No, then leave immediately
	move.l	d7,d0			! move Remainder to result register
finish2:
	move.l	a0,d6			! restore data registers that are corrupted
	move.l	a1,d7			! ... from unused address registers
	rts

!
!	The following routines are the assign versions of the routines
!
	XDEF	.Xasldiv
.Xasldiv:
	lea	.Xldiv(pc),a1
	bra	do_asl			! now join shared code

	XDEF	.Xaslrem
.Xaslrem:
	lea	.Xlrem(pc),a1
	bra	do_asl

	XDEF	.Xasuldiv
.Xasuldiv:
	lea	.Xuldiv(pc),a1
	bra	do_asl

	XDEF	.Xasulrem
.Xasulrem:
	lea	.Xulrem(pc),a1

!	Code common to all the assign variants

do_asl:
	move.l	4+4+0(a7),-(a7) 	! copy across original second parameter
	move.l	0+4+4(a7),a0		! get original first parameter
	move.l	(a0),-(a7)		! ... and store its target as new param
	jsr	(a1)			! go and execute required routine
	move.l	0+4+0(a7),a0		! get original first param
	move.l	d0,(a0) 		! ... and store result at its target
	bra	tidyup			! exit tidying up stack

	END
