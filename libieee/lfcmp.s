#
* C68 12 byte floating point compare routine
*-----------------------------------------------------------------------------
*  #1  Based on dfcmp() routine 								-djw-	02/97
*-----------------------------------------------------------------------------

#include "ieeeconf.h"

	SECTION text

	XDEF	.Xlfcmp

SAVEREG = 5*4		! Size of saved registers on stack

*----------------------------------------
*	sp	Return address
*	sp+4	address of second operand
*	sp+8	address of first operand
*----------------------------------------
.Xlfcmp:
	movem.l d2-d6,-(sp) 		! Save registers that will be corruptedd
	move.l	SAVEREG+4(sp),a1	! address of second operand
	movem.l (a1),d1/d2/d3
	move.l	SAVEREG+8(sp),a1	! address of first operand
	movem.l (a1),d4/d5/d6

	tst.l	d1			! check sign bit of first operand
	bpl 	3f			! ... and jump if not negative
	neg.l	d3			! negate last bit
	negx.l	d2			! negate middle bit
	negx.l	d1			! ... and first bit
	bchg	#31,d1			! toggle sign bit
3:
	tst.l	d4			! check sign bit of second operand
	bpl 	6f			! ... and jump if not negative
	neg.l	d6			! negate last bit
	negx.l	d5			! negate middle bit
	negx.l	d4			! negate first bit
	bchg	#31,d4			! toggle sign bit
6:
	cmp.l	d4,d1			! compare first sections of operands
	blt 	lt
	bgt 	gt
	cmp.l	d5,d2			! equal so compare middle section of operands
	blt 	lt
	bgt 	gt
	cmp.l	d6,d3			! equal - so compare last section of operands
	bhi 	gt
	beq 	eq

lt:	moveq	#-1,d0
	bra 	finish

eq:	moveq	#0,d0
	bra 	finish

gt:	moveq	#1,d0

finish:
	movem.l (sp)+,d2-d6		! restore changed registers
	move.l	(sp)+,a1		! get return address
	add.l	#8,sp			! remove 2 parameters from stack
	jmp 	(a1)			! ... and return

#ifdef GCC_MATH_FULL

	XDEF	.GXlfcmp

*----------------------------------------
*	sp	Return address
*	sp+4	address of second operand
*	sp+8	address of first operand
*----------------------------------------
.GXlfcmp:
	movem.l d2-d6,-(sp) 		! Save registers that will be corruptedd
	move.l	SAVEREG+4(sp),a1	! address of second operand
	movem.l (a1),d1/d2/d3
	move.l	SAVEREG+8(sp),a1	! address of first operand
	movem.l (a1),d4/d5/d6

	tst.l	d1			! check sign bit of first operand
	bpl 	G3f			! ... and jump if not negative
	neg.l	d3			! negate last bit
	negx.l	d2			! negate middle bit
	negx.l	d1			! ... and first bit
	bchg	#31,d1			! toggle sign bit
G3:
	tst.l	d4			! check sign bit of second operand
	bpl 	G6f			! ... and jump if not negative
	neg.l	d6			! negate last bit
	negx.l	d5			! negate middle bit
	negx.l	d4			! negate first bit
	bchg	#31,d4			! toggle sign bit
G6:
	cmp.l	d4,d1			! compare first sections of operands
	blt 	Glt
	bgt 	Ggt
	cmp.l	d5,d2			! equal so compare middle section of operands
	blt 	Glt
	bgt 	Ggt
	cmp.l	d6,d3			! equal - so compare last section of operands
	bhi 	Ggt
	beq 	Geq

Glt:	moveq	#-1,d0
	rts

Geq:	moveq	#0,d0
	rts

Ggt:	moveq	#1,d0
	rts

#endif /* GCC_MATH */

	END
