#
* C68 4 byte floating point compare routine
*-----------------------------------------------------------------------------
* ported to 68000 by Kai-Uwe Bloem, 12/89
*  #1  Based on 8 byte routine	   Dave Walker		   05/92
*  #2  Changed entry/exit code for C68 v4.3 compatibility	   09/93
*  #3  Changes to support macroized assembler directives	   -djw-   02/97
*-----------------------------------------------------------------------------

#include "ieeeconf.h"

	SECTION text

	XDEF   .Xsfcmp

*----------------------------------------
*	sp	Return address
*	sp+4	address of second operand
*	sp+8	address of first operand
*----------------------------------------
.Xsfcmp:
	move.l	4(sp),a0	! address of second operand
	move.l	8(sp),a1	! address of first operand
	move.l	(a0),d1
	move.l	(a1),d2

	tst.l	d1		! check sign bit of first operand
	bpl 	3f		! ... and jump if not negative
	neg.l	d1		! negate
	bchg	#31,d1		! toggle sign bit
3:
	tst.l	d2		! check sign bit of second operand
	bpl 	6f		! ... and jump if not negative
	neg.l	d2		! negate
	bchg	#31,d2		! toggle sign bit
6:
	cmp.l	d2,d1		! compare operands
	bgt 	gt
	beq 	eq

lt:	moveq	#-1,d0
	bra 	finish

gt:	moveq	#1,d0
	bra 	finish

eq:	moveq	#0,d0

finish:
	move.l	(sp)+,a0	! get return address
	addq.l	#8,sp		! remove 2 parameters from stack
	jmp 	(a0)		! ... and return

#ifdef GCC_MATH_FULL

	XDEF   .GXsfcmp

*----------------------------------------
*	sp	Return address
*	sp+4	address of second operand
*	sp+8	address of first operand
*----------------------------------------
.GXsfcmp:
	move.l	4(sp),a0	! address of second operand
	move.l	8(sp),a1	! address of first operand
	move.l	(a0),d1
	move.l	(a1),d2

	tst.l	d1		! check sign bit of first operand
	bpl 	G3		! ... and jump if not negative
	neg.l	d1		! negate
	bchg	#31,d1		! toggle sign bit
G3:
	tst.l	d2		! check sign bit of second operand
	bpl 	G6		! ... and jump if not negative
	neg.l	d2		! negate
	bchg	#31,d2		! toggle sign bit
G6:
	cmp.l	d2,d1		! compare operands
	bgt 	Ggt
	beq 	Geq

Glt:	moveq	#-1,d0
	rts

Ggt:	moveq	#1,d0
	rts

Geq:	moveq	#0,d0
	rts

#endif /* GCC_MATH */

	END
