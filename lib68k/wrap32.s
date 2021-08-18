#
!	wrap32.s
!
!	Wrapper routine to help test 32 bit support routines
!
!	Amendmet History:
!	~~~~~~~~~~~~~~~~~
!	25 Aug 00	DJW   - First Version

#include "68kconf.h"

	SECTION TEXT

!	Routines that take two long long parameters and a results pointer

	XDEF	_Xlmul
	XDEF	_Xulmul
	XDEF	_Xldiv
	XDEF	_Xuldiv
	XDEF	_Xlrem
	XDEF	_Xulrem

	XREF	.Xlmul
	XREF	.Xulmul
	XREF	.Xldiv
	XREF	.Xuldiv
	XREF	.Xlrem
	XREF	.Xulrem

_Xlmul:
	lea 	.Xlmul,a0
	bra 	shared

_Xulmul:
	lea 	.Xulmul,a0
	bra 	shared

_Xldiv:
	lea 	.Xldiv,a0
	bra 	shared

_Xuldiv:
	lea 	.Xuldiv,a0
	bra 	shared

_Xlrem:
	lea 	.Xlrem,a0
	bra 	shared

_Xulrem:
	lea 	.Xulrem,a0
	bra 	shared

shared:
	lea 	rtsaddr(pc),a1
	move.l	(a7)+,(a1)			! save return address
	jsr 	(a0)				! call support routine
	move.l	(a7),a0 			! get results area address
	move.l	d0,(a0) 			! move results to results area
	move.l	rtsaddr(pc),a0		! get original return address
	sub.l	#8,a7				! pretend parameters were NOT removed
	jmp 	(a0)				! return to calling point


rtsaddr:
	dc.l	0


!	Assign op routines

	XDEF	_Xaslmul
	XDEF	_Xasulmul
	XDEF	_Xasldiv
	XDEF	_Xasuldiv
	XDEF	_Xaslrem
	XDEF	_Xasulrem

	XREF	.Xaslmul
	XREF	.Xasulmul
	XREF	.Xasldiv
	XREF	.Xasuldiv
	XREF	.Xaslrem
	XREF	.Xasulrem

_Xaslmul:
	lea 	.Xaslmul,a0
	bra 	shared_as

_Xasulmul:
	lea 	.Xasulmul,a0
	bra 	shared_as

_Xasldiv:
	lea 	.Xasldiv,a0
	bra 	shared_as

_Xasuldiv:
	lea 	.Xasuldiv,a0
	bra 	shared_as

_Xaslrem:
	lea 	.Xaslrem,a0
	bra 	shared_as

_Xasulrem:
	lea 	.Xasulrem,a0

shared_as:
	lea 	rtsaddr(pc),a1
	move.l	(a7)+,(a1)			! save return address

	jsr 	(a0)				! call support routine

	sub.l	#8,a7				! pretend parameters NOT removed
	move.l	rtsaddr(pc),a0		! get original return address
	jmp 	(a0)				! return to calling point

	END
