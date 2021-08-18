#
! c68 support routine
! ~~~~~~~~~~~~~~~~~~~
!
! multiplication of long quantities
!
! a=2^16*a1+a2
! b=2^16*b1+b2
!
! a*b=2^16*(a1*b2+a2*b1)+a2*b2 (jedenfalls modulo 2^32)
!
! Amendment History
! ~~~~~~~~~~~~~~~~~~
! #1  11 Dec 92 Changed exit code to tidy up stack. 	Dave Walker
! #2  18 Jul 94 Merged signed/unsigned routines.		Dave Walker
! #3  13 Aug 94 Used common tidyup code for all exit paths. Dave Walker
! #4  18 Sep 00 Converted directives to macrosized versions Dave Walker
!

#include "68kconf.h"

	SECTION  TEXT
	SECTION  ROM
	SECTION  DATA
	SECTION  BSS
!
! Export: .Xlmul,  .Xaslmul
!	  .Xulmul, .Xasulmul
!
	SECTION TEXT
	XDEF	.Xlmul
.Xlmul:
	clr.w	d2
	tst.l	4(a7)
	bge	_1
	neg.l	4(a7)
	not.w	d2
_1:
	tst.l	8(a7)
	bge	_2
	neg.l	8(a7)
	not.w	d2
_2:
	bsr	shared

! Test, ob noch negiert werden muss

	tst.w	d2
	beq	tidyup
	neg.l	d0
tidyup:
	move.l	(a7)+,a0	! get return address
	lea	8(a7),a7	! remove two long parameters
	jmp	(a0)		! return to calling code

	XDEF	.Xulmul
.Xulmul:
	bsr	shared
	bra	tidyup
!
!	Shared code (this bit does unsigned multiply)
!
shared:
	move.w	4+4(a7),d1
	mulu	10+4(a7),d1
	move.w	6+4(a7),d0
	mulu	8+4(a7),d0
	add.l	d0,d1
	swap	d1
	clr.w	d1
	move.w	6+4(a7),d0
	mulu	10+4(a7),d0
	add.l	d1,d0
	rts

	XDEF	.Xaslmul
.Xaslmul:
	lea 	.Xlmul(pc),a0
	bra 	do_asl
!
	XDEF	.Xasulmul
.Xasulmul:
	lea 	.Xulmul(pc),a0
!
do_asl:
	move.l	8(a7),a1	! second operand
	move.l	a1,-(a7)	! store copy of second operand
	move.l	8(a7),a1	! pointer to first operand
	move.l	(a1),-(a7)	! store value for first operand
	jsr 	(a0)		! Call required routine
!				  a1 not destroyed (but stack tidied)
	move.l	d0,(a1) 	! assign result
	bra 	tidyup		! exit via shared tidyup code

	END
