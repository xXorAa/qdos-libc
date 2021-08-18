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
! #1  01 Oct 00 Written from Xmul.s (but better optimized)	Thierry Godefroy

#include "68kconf.h"

#ifdef GCC_MATH

	SECTION  TEXT
	SECTION  ROM
	SECTION  DATA
	SECTION  BSS
!
! Export: .GXlmul,  .GXaslmul
!	  .GXulmul, .GXasulmul
!
	SECTION TEXT
	XDEF	.GXlmul
.GXlmul:
	lea	4(sp),a0
	clr.w	d2
	tst.l	(a0)
	bge	_1
	neg.l	(a0)
	not.w	d2
_1:
	tst.l	4(a0)
	bge	_2
	neg.l	4(a0)
	not.w	d2
_2:
	bsr	shared

! Test, ob noch negiert werden muss

	tst.w	d2
	beq 	_3
	neg.l	d0
_3:
	rts

	XDEF	.GXulmul
.GXulmul:
	lea	4(sp),a0
shared:
	move.w	(a0)+,d1
	move.w	(a0)+,d0
	mulu	(a0)+,d0
	mulu	(a0),d1
	add.l	d0,d1
	swap	d1
	clr.w	d1
	move.w	-4(a0),d0
	mulu	(a0),d0
	add.l	d1,d0
	rts

	XDEF	.GXaslmul
.GXaslmul:
	lea	.GXlmul(pc),a0
	bra	do_asl

	XDEF	.GXasulmul
.GXasulmul:
	lea	.GXulmul(pc),a0

do_asl:
	move.l	8(sp),a1	! second operand
	move.l	a1,-(sp)	! store copy of second operand
	move.l	8(sp),a1	! pointer to first operand
	move.l	(a1),-(sp)	! store value for first operand
	jsr	(a0)		! Call required routine (a1 not destroyed)
	addq.l	#8,sp		! tidy up the stack
	move.l	d0,(a1) 	! assign result
	rts

#endif /* GCC_MATH */

	END
