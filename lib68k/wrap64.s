#
!	wrap64.s
!
!	Wrapper routine to help test 64 bit support routines
!
!	Amendmet History:
!	~~~~~~~~~~~~~~~~~
!	09 Aug 00	DJW   - First Version

#include "68kconf.h"

	SECTION TEXT

!	Routines that take two long long parameters and a results pointer

	XDEF	_Xllmul
	XDEF	_Xullmul
	XDEF	_Xlldiv
	XDEF	_Xulldiv
	XDEF	_Xllrem
	XDEF	_Xullrem

	XREF	.Xllmul
	XREF	.Xullmul
	XREF	.Xlldiv
	XREF	.xulldiv
	XREF	.Xllrem
	XREF	.Xullrem

_Xllmul:
	lea 	.Xllmul,a0
	bra 	shared88

_Xullmul:
	lea 	.Xullmul,a0
	bra 	shared88

_Xlldiv:
	lea 	.Xlldiv,a0
	bra 	shared88

_Xulldiv:
	lea 	.Xulldiv,a0
	bra 	shared88

_Xllrem:
	lea 	.Xllrem,a0
	bra 	shared88

_Xullrem:
	lea 	.Xullrem,a0
	bra 	shared88

shared88:
	lea 	rtsaddr(pc),a1
	move.l	(a7)+,(a1)			! save return address
	jsr 	(a0)				! call support routine
	move.l	(a7),a0 			! get results area address
	move.l	d0,(a0) 			! move results to results area
	move.l	d1,4(a0)
	move.l	rtsaddr(pc),a0		! get original return address
	sub.l	#16,a7				! pretend parameters were NOT removed
	jmp 	(a0)				! return to calling point

	XDEF	_Xllshl
	XDEF	_Xullshl
	XDEF	_Xllshr
	XDEF	_Xullshr

	XREF	.Xllshl
	XREF	.Xullshl
	XREF	.Xllshr
	XREF	.xullshr

_Xllshl:
	lea 	.Xllshl,a0
	bra 	shared84

_Xullshl:
	lea 	.Xullshl,a0
	bra 	shared84

_Xllshr:
	lea 	.Xllshr,a0
	bra 	shared84

_Xullshr:
	lea 	.Xullshr,a0
	bra 	shared84

shared84:
	lea 	rtsaddr(pc),a1
	move.l	(a7)+,(a1)			! save return address
	jsr 	(a0)				! call support routine
	move.l	(a7),a0 			! get results area address
	move.l	d0,(a0) 			! move results to results area
	move.l	d1,4(a0)
	move.l	rtsaddr(pc),a0		! get original return address
	sub.l	#12,a7				! pretend parameters were NOT removed
	jmp 	(a0)				! return to calling point

rtsaddr:
	dc.l	0

!	Routines that take pointer to long long and a long long parameter

	XDEF	_Xasllmul
	XDEF	_Xasullmul
	XDEF	_Xaslldiv
	XDEF	_Xasulldiv
	XDEF	_Xasllrem
	XDEF	_Xasullrem

	XREF	.Xasllmul
	XREF	.Xasullmul
	XREF	.Xaslldiv
	XREF	.Xasulldiv
	XREF	.Xasllrem
	XREF	.Xasullrem

_Xasllmul:
	lea 	.Xasllmul,a0
	bra 	shared_as8

_Xasullmul:
	lea 	.Xasullmul,a0
	bra 	shared_as8

_Xaslldiv:
	lea 	.Xaslldiv,a0
	bra 	shared_as8

_Xasulldiv:
	lea 	.Xasulldiv,a0
	bra 	shared_as8

_Xasllrem:
	lea 	.Xasllrem,a0
	bra 	shared_as8

_Xasullrem:
	lea 	.Xasullrem,a0

shared_as8:
	lea 	rtsaddr(pc),a1
	move.l	(a7)+,(a1)			! save return address

	jsr 	(a0)				! call support routine

	sub.l	#12,a7				! pretend parameters NOT removed
	move.l	rtsaddr(pc),a0		! get original return address
	jmp 	(a0)				! return to calling point

shared_as4:
	lea 	rtsaddr(pc),a1
	move.l	(a7)+,(a1)			! save return address

	jsr 	(a0)				! call support routine

	sub.l	#8,a7				! pretnd parameters NOT removed
	move.l	rtsaddr(pc),a0		! get original return address
	jmp 	(a0)				! return to calling point


	XDEF	_Xasllshl
	XDEF	_Xasullshl
	XDEF	_Xasllshr
	XDEF	_Xasullshr

	XREF	.Xasllshl
	XREF	.Xasullshl
	XREF	.Xasllshr
	XREF	.Xasullshr

_Xasllshl:
	lea 	.Xasllshl,a0
	bra 	shared_as4

_Xasullshl:
	lea 	.Xasullshl,a0
	bra 	shared_as4

_Xasllshr:
	lea 	.Xasllshr,a0
	bra 	shared_as4

_Xasullshr:
	lea 	.Xasullshr,a0
	bra 	shared_as4

	END
