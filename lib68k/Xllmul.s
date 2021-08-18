#
! c68 support routine
! ~~~~~~~~~~~~~~~~~~~
!
! multiplication of long long quantities
!
! Prototypes:
!	long long			.Xllmul  (long long a, long long b);
!	unsigned long long	.Xllmul  (unsigned long long a, unsigned long long b);
!	void				.Xasllmul (long long *a, long long b);
!	void				.Xasllmul (unsigned long long *a, unsigned long long *b);
!
! Using the following two assumptions:
!  a) Only 16bit * 16 bit multiply is supported by the instruction set
!  b) We are working with modulo 64 arithmetic
!
! then if
!
! a = 2^48*a1 + 2^32*a2 + 2^16*a3 + a4
! b = 2^48*b1 + 2^32*b2 + 2^16*b3 + b4
!
! a*b = 2^48 * (a1*b4 + a2*b3 + a3*b2 + a4*b1)
!	  + 2^32 * (a2*b4 + a3*b3 + a4*b2)
!	  + 2^16 * (a3*b4 + a4*b3)
!	  + (a4*b4)
!
! Register Usage:
!	 D0, D1 	64 bit final Results
!	 D2 		Sign result
!	 D3 		32-bit Work register for calculations
!	 D4 		32-bit temporary result area (when do not need more bits)
!	 D4,D5		64-bit temporary result area

! Amendment History
! ~~~~~~~~~~~~~~~~~~
! #1  05 Aug 00 First version for 'long long'support.	Dave Walker
! #2  18 Sep 00 Converted directives to macrosized versions Dave Walker
!

#include "68kconf.h"

	SECTION TEXT
	SECTION ROM
	SECTION DATA
	SECTION BSS

	SECTION TEXT

	XDEF	.Xllmul

.Xllmul:
	clr.w	d2					! Pre-set for positive result
	tst.l	4+0(a7) 			! Check sign of a
	bge 	a_pos				! Jump if positive
	neg.l	4+4(a7) 			! negate a
	negx.l	4+0(a7) 			!
	not.w	d2					! invert result type
a_pos:
	tst.l	4+8(a7) 			! Check sign of b
	bge 	b_pos				! Jump if positive
	neg.l	4+8+4(a7)			! negate b
	negx.l	4+8+0(a7)			!
	not.w	d2					! invert result type
b_pos:
	bsr shared

!	Decide if we need to negate the result

	tst.w	d2					! Check result type required
	beq 	tidyup				! jump if positive
	neg.l	d1					! negate if negative
	negx.l	d0
tidyup:
	move.l	(a7)+,a0			! get return address
	lea 	16(a7),a7			! remove two long long parameters
	jmp 	(a0)				! return to calling code

	XDEF	.Xullmul
.Xullmul:
	bsr 	shared
	bra 	tidyup
!
!	Shared code (this bit does unsigned multiply)
!	branch optimisations assume that branch is faster
!	than doing a multiply by zero - needs to be checked
!
SAVEREG EQU 4*4+4+4
A_1 EQU 	SAVEREG+0
A_2 EQU 	SAVEREG+2
A_3 EQU 	SAVEREG+4
A_4 EQU 	SAVEREG+6
B_1 EQU 	SAVEREG+8
B_2 EQU 	SAVEREG+10
B_3 EQU 	SAVEREG+12
B_4 EQU 	SAVEREG+14

shared:
	movem.l d3/d4/d5/d6,-(a7)		  ! save work registers
	moveq	#0,d0
	moveq	#0,d1
	moveq	#0,d3
	moveq	#0,d4
	moveq	#0,d5
	moveq	#0,d6

!		(a4*b4)
!		32 bit answer direct to d1

	move.w	A_4(a7),d1
	beq 	_1
	mulu	B_4(a7),d1

!		2^32 * (a2*b4 + a3*b3 + a4*b2)
!		32 bit answer direct to d0 ignoring overflow
_1:
	move.w	A_2(a7),d0
	beq 	_2
	mulu	B_4(a7),d0
_2:
	move.w	A_3(a7),d3
	beq 	_3
	mulu	B_3(a7),d3
	add.l	d3,d0
_3:
	move.w	A_4(a7),d3
	beq 	_4
	mulu	B_2(a7),d3
	add.l	d3,d0

!		2^16 * (a3*b4 + a4*b3)
_4:
	move.w	A_3(a7),d3
	beq 	_5
	mulu	B_4(a7),d3
	add.l	d3,d5
	addx.l	d6,d4
_5:
	move.w	A_4(a7),d3
	beq 	_6
	mulu	B_3(a7),d3
	add.l	d3,d5
	addx.l	d6,d4
_6:
	swap	d4						! Multiply by 2^16
	swap	d5
	move.w	d5,d4
	move.w	d6,d5
	add.l	d5,d1					! add in least significant bit
	addx.l	d4,d0					! then most significant bit

!		a*b = 2^48 * (a1*b4 + a2*b3 + a3*b2 + a4*b1)
!		only going to use least significant 16 bits of answer

	move.w	A_1(a7),d4
	mulu	B_4(a7),d4

	move.w	A_2(a7),d3
	beq 	_7
	mulu	B_3(a7),d3
	add.l	d3,d4
_7:
	move.w	A_3(a7),d3
	beq 	_8
	mulu	B_2(a7),d3
	add.l	d3,d4
_8:
	move.w	A_4(a7),d3
	beq 	_9
	mulu	B_1(a7),d3
	add.l	d3,d4
_9:
	swap	d4
	clr.w	d4
	add.l	d4,d0

	movem.l (a7)+,d3/d4/d5/d6		! restore work registers
	rts



	XDEF	.Xasllmul
.Xasllmul:
	lea 	.Xllmul(pc),a0
	bra 	do_asl
!
	XDEF	.Xasullmul
.Xasullmul:
	lea 	.Xullmul(pc),a0
!
do_asl:
	lea 	8(a7),a1		! second operand
	move.l	4(a1),-(a7) 	! store copy of second operand
	move.l	(a1),-(a7)		!
	move.l	12(a7),a1		! pointer to first operand
	move.l	4(a1),-(a7) 	! store value for first operand
	move.l	(a1),-(a7)		!
	jsr 	(a0)			! Call required routine
!				  a1 not destroyed (but stack tidied)
	move.l	d1,4(a1)		! assign bottom half of result
	move.l	d0,(a1) 		! assign top half of result

	move.l	(a7)+,a0		! get return address
	lea 	12(a7),a7		! remove pointer + long long parameters
	jmp 	(a0)			! return to calling code

	END
