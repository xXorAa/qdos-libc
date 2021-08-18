#
! c68 Support routine
! ~~~~~~~~~~~~~~~~~~~
! quotient and remainder of long long quantities
!
! Amendement History
! ~~~~~~~~~~~~~~~~~~
! #1  27 Aug 00 First version.	Based on long divide.
! #2  18 Sep 00 Converted directives to macrosized versions Dave Walker
!

#include "68kconf.h"

	SECTION TEXT
	SECTION ROM
	SECTION DATA
	SECTION BSS
!
! Export: .Xlldiv,	.Xllrem,  .Xaslldiv,  .Xasllrem
!	  .Xulldiv, .Xullrem, .Xasulldiv, .Xasullrem
!
	SECTION TEXT

	XREF	.Xuldiv

!	Calculate remainder/result of dividing two longs

	XDEF	.Xllrem
.Xllrem:
	move.l	#1,d2		! Rest gewuenscht: Flag <> 0
	bra 	do_divs
!
	XDEF	.Xlldiv
.Xlldiv:
	move.l	#0,d2		! Quotient gewuenscht: Flag =0

!	Code common to divide/remainder of signed quantities

do_divs:
	tst.l	4+0(a7) 	! Dividend
	bge 	_1			! positive ? - YES, jump
	neg.l	4+4(a7) 	! NO - negate dividend
	negx.l	4+0(a7)
	bchg	#31,d2		! invert D2 sign bit
_1:
	tst.l	4+8(a7) 	! Divisor
	bge 	_3			! Divisor positive ? - YES jump
	neg.l	4+12(a7)	! NO - negate divisor
	negx.l	4+8(a7)
	bchg	#31,d2		! toggle D2 sign bit
_3:
!
!  both Operands now have positive sign
!  Use shared routine that does unsigned multiply
!
	bsr 	shared		! call shared code to do calculation

!	Remainder required instead ?

	tst.w	d2			! remainder wanted?
	bne 	_10 		! ... yes, go and handle it then
!
!	Quotient required - check sign OK
!
	tst.l	d2			! Quotient negative? (Rest immer positiv)
	bpl 	tidyup		! ... no, then exit immediately
	bra 	negate_answer
!
_10:
!
!	Remainder required
!	N.B.	Answer must have same sign as dividend as we use
!			a round towards zero strategy for division
!
	tst.l	4(a7)		! Check sign of Dividend
negate_answer:
	bge 	tidyup		! positive/zero merely exit
	neg.l	d1			! ... else negate answer
	negx.l	d0

!
!	Code common to all direct exit paths
!
tidyup:
	move.l	(a7)+,a0	! get return address
	lea 	16(a7),a7	! remove two long long parameters
	jmp 	(a0)		! return to calling code

!
!	Calculate remainder/result of dividing two unsigned longs
!
	XDEF	.Xullrem
.Xullrem:
	move.l	#1,d2		! Rest gewuenscht: Flag <> 0
	bra 	do_divu

	XDEF	.Xulldiv
.Xulldiv:
	move.l	#0,d2		! Quotient gewuenscht: Flag =0
!
!	Code common to unsigned dive/remainder
!
do_divu:
	bsr 	shared		! call code common to all variants
	bra 	tidyup		! ... and now leave

!
!	Shared code for signed/unsigned modes
!
!	Optimisations that can be done:
!	a)	If both divisor and dividend only have 32 bits of significance
!		then use 32 bit divide routine and extend result(s)
!	b)	If divisor is only 16 bits then use hardware devide.
!	c)	If at any time remainder is zero, then can exit subtract/shift
!		loop immediately regardless of current value of scale factor.
!
!	Register Usage:
!		d0/d1		Quotient
!		d2/d3		Scaling Factor
!		d4/d5		Divisor
!		d6/d7		Dividend/Remainder
!
SAVEREG EQU 6*4+4+4
shared:
	movem.l d2/d3/d4/d5/d6/d7,-(a7)   ! save registers corrupted
	move.l	#0,d0				! Quotient set to 0
	moveq	#0,d1

!	Start by seeing if we could use 32 bit routines?
!	Also check for dividend or divisor being zero as special cases

	move.l	SAVEREG+4(a7),d7	! Dividend
	move.l	SAVEREG+0(a7),d6
	bne 	top64				! jump if most significant part not zero ?
	tst.l	d7					! Check least significant part for zero
	beq 	finish				! ... YES, exit immediately with zero result
top64:
	move.l	SAVEREG+12(a7),d5	! Divisor
	move.l	SAVEREG+8(a7),d4
	bne 	div64
	tst.l	d5
	bne 	plusbottom
zerodiv:
	divs	#0,d0				! EXCEPTION
	movem.l (a7)+,d2/d3/d4/d5/d6/d7 		! restore saved registers
	lea 	4(a7),a7			! remove return address
	bra 	tidyup

!	If both top and bottom are zero in most significant part
!	then we can optimise by using the 32 bit divide logic

plusbottom:
	tst.l	d6					! check if top half also only 32 bites
	bne 	div64				! ... YES we can use 32 bit divide
div32:
	move.l	d7,-(a7)
	move.l	d5,-(a7)
	jsr 	.Xuldiv
	move.l	d0,d1
	moveq	#0,d0
	bra 	finish

!	We really need 64 bit routines - so get ready to use them

div64:
	move.w	d2,a0				! ... save remainder flag for later

	cmp.l	d6,d4				! compare most significant parts
	bcs 	notequal
	bne 	finish
	cmp.l	d7,d5				! compare least signifcant parts
	bcs 	notequal			! Dividend > Divisor
	bne 	finish				! Dividend < Divisor
								!	Quotient=0, Rest=Divisor
!
!  Special case of values being equal
!
equal:
	move.l	#1,d1				! Quotient=1
	move.l	#0,d6				! Remainder=0
	move.l	#0,d7
	bra 	finish

!	Check for special case of dividend being less that 65536 which
!	means we can safely exploit the hardware divide instruction!

notequal:
!	 tst.l	 d4 				 ! check most significant part
!	 bne	 _6
!	 tst.l	 d5
!	 bne	 _6
!	 cmp.l	 #0x10000,d7
!	 bcc	 _6 				 ! Dividend > 65536

!	Use hardware divide

!div16:
!	 divu	 d6,d7
!	 move.w  d7,d0
!	 clr.w	 d7
!	 swap	 d7
!	 bra	 finish
!
!	We must use the brute force method off subtracting/shifting
!
_6:
	moveq	#0,d2				! Initialise scaling factor
	move.l	#1,d3

!	Calculate the initial scaling factor
_7:
	tst.l	d4			! value is greater than 2^63 (only happens in unsigned cases)
	bmi 	_8			! ... YES, we better start the subtraction loop then
	cmp.l	d4,d6				! Check most significant part
	bcs 	_8					! .. if ready then start loop
	bne 	_7a 				! if not same then jump
	cmp.l	d5,d7				! Check least significant part
	bcc 	_8					! if ready then start loop
!
! kein Check, ob das Bit schon draussen ist (wie bei udiv), da die
! Operanden kleiner als 2^31 sind
!
_7a:
	add.l	d5,d5				! multiply divisor by power of 2
	addx.l	d4,d4				! ... + carry for Most significant part
	add.l	d3,d3				! multiply scaling factor by power of 2
	addx.l	d2,d2				! ... + carry for msot significant part
	bra 	_7					! go back and try again

!	Do divide by repeated subtractions and shifts
!	This is slowest method but works for any value

_8:
	tst.l	d2					! check if we have finished (scale factor = 0)
	bne 	_8a
	tst.l	d3
	beq 	finish				! ... if so must have finished

!	Check for correct scaling factor

_8a:
	cmp.l	d4,d6				! compare most significant bits
	bcs 	_9					! ... and reduce scaling if divisor too large
	bne 	_8b 				! if not equal then go to do calc
	cmp.l	d5,d7				! check least significant bits
	bcs 	_9					! ... and reduce scaling if divisor too large

!	Scaling factor correct - do subtraction

_8b:
	or.l	d2,d0				! set bit in answer for current scale factor
	or.l	d3,d1
	sub.l	d5,d7				! subtract scaled divisor from dividend
	subx.l	d4,d6

!		Small optimisation - check for exact division completed
!		(not sure if test overhead is offset by gains in real world?)

	bne 	_9					! if this part not zero continue
	tst.l	d7					! ... check least significant part for zero
	beq 	finish				! ... and if also zero, exit immediately

!	Get ready for next time around the loop

_9:
	lsr.l	#1,d3				! Reduce scaling factor by power of 2
	lsr.l	#1,d2
	bcc 	_9a
	bset	#31,d3
_9a:
	lsr.l	#1,d5				! shift up divisor by power of 2
	lsr.l	#1,d4
	bcc 	_8
	bset	#31,d5				! ... set top bit of least significant part
	bra 	_8
!
finish:
!
! Quotient in d0/d1, Remainder in d6/d7
!
	move.w	a0,d2				! Remainder wanted (checking saved flag)?
	beq 	finish2 			! No, then leave immediately
	move.l	d6,d0				! move Remainder to result registers
	move.l	d7,d1
finish2:
	movem.l (a7)+,d2/d3/d4/d5/d6/d7   ! restore saved registers
	rts

!
!	The following routines are the assign versions of the routines
!
	XDEF	.Xaslldiv
.Xaslldiv:
	lea 	.Xlldiv(pc),a1
	bra 	do_asl			! now join shared code

	XDEF	.Xasllrem
.Xasllrem:
	lea 	.Xllrem(pc),a1
	bra 	do_asl

	XDEF	.Xasulldiv
.Xasulldiv:
	lea 	.Xulldiv(pc),a1
	bra 	do_asl

	XDEF	.Xasullrem
.Xasullrem:
	lea 	.Xullrem(pc),a1

!	Code common to all the assign variants

do_asl:
	move.l	4+4+4(a7),-(a7) 	! copy across original second parameter
	move.l	4+8+0(a7),-(a7)
	move.l	4+8+0(a7),a0		! get original first parameter
	move.l	4(a0),-(a7) 		! ... and store its target as new param
	move.l	(a0),-(a7)
	jsr 	(a1)				! go and execute required routine
	move.l	0+4+0(a7),a0		! get original first parameter
	move.l	d0,(a0)+			! ... and store result at its target
	move.l	d1,(a0)
	move.l	(a7)+,a0			! get return address
	lea 	12(a7),a7			! remove address + long long parameters
	jmp 	(a0)				! return to calling code

	END
