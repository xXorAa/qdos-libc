#
* C68 8 byte floating point compare routine
*-----------------------------------------------------------------------------
* ported to 68000 by Kai-Uwe Bloem, 12/89
*  #1  original author: Peter S. Housel 6/3/89
*  #2  Redid register usage, and then added wrapper routine
*  to provide C68 IEEE compatibility.
*  Also added C68 test routines 	   Dave & Keith Walker 02/92
*  #3  Avoided corrupting passed value if negative	  Dave Walker	   04/92
*  #4  Added code to treat as equal if only different by a value
*  equivalent to a bit in the least significant position	   05/92
*  #5  Changed entry point names for C68 v4.3 compatibility
*  Changed exit code for C68 v4.3 compatibility
*  Removed ACK entry points 			   -djw-   09/93
*  #6  Removed "nearly equal" code as incorrect 	   -djw-   10/93
*  #7  Corrected bug in comparing second 4 bytes	   -djw-   11/95
*  #8  Correct reversed test on second 4 bytes		   -djw-   03/96
*  #9  Changes to support macroized assembler directives	   -djw-   02/97
*		Changes to supported macroized	HW_FPU interface
*-----------------------------------------------------------------------------

#include "ieeeconf.h"

	SECTION text

	XDEF	.Xdfcmp

SAVEREG = 3*4		! Size of saved registers on stack

*----------------------------------------
*	sp	Return address
*	sp+4	address of second operand
*	sp+8	address of first operand
*----------------------------------------
.Xdfcmp:
	movem.l d2-d4,-(sp) 		! Save registers that will be corruptedd
	move.l	SAVEREG+4(sp),a1	! address of second operand
	movem.l (a1),d1/d2
	move.l	SAVEREG+8(sp),a1	! address of first operand
	movem.l (a1),d3/d4

	tst.l	d1			! check sign bit of first operand
	bpl 	3f			! ... and jump if not negative
	neg.l	d2			! negate 2nd half
	negx.l	d1			! ... and first half
	bchg	#31,d1			! toggle sign bit
3:
	tst.l	d3			! check sign bit of second operand
	bpl 	6f			! ... and jump if not negative
	neg.l	d4			! negate 2nd half
	negx.l	d3			! negate first half
	bchg	#31,d3		 	! toggle sign bit
6:
	cmp.l	d3,d1			! compare first halves of operands
	blt 	lt
	bgt 	gt
	cmp.l	d4,d2			! equal - so compare second halves of operands
	bhi 	gt
	beq 	eq

lt:	moveq	#-1,d0
	bra 	finish

eq:	moveq	#0,d0
	bra 	finish

gt:	moveq	#1,d0

finish:
	movem.l (sp)+,d2-d4		! restore changed registers
	move.l	(sp)+,a1		! get return address
	addq.l	#8,sp			! remove 2 parameters from stack
	jmp 	(a1)			! ... and return

#ifdef GCC_MATH_FULL

	XDEF	.GXdfcmp

*----------------------------------------
*	sp	Return address
*	sp+4	address of second operand
*	sp+8	address of first operand
*----------------------------------------
.GXdfcmp:
	movem.l d2-d4,-(sp)		! Save registers that will be corruptedd
	move.l	SAVEREG+4(sp),a1	! address of second operand
	movem.l (a1),d1/d2
	move.l	SAVEREG+8(sp),a1	! address of first operand
	movem.l (a1),d3/d4

	tst.l	d1			! check sign bit of first operand
	bpl 	G3			! ... and jump if not negative
	neg.l	d2			! negate 2nd half
	negx.l	d1			! ... and first half
	bchg	#31,d1			! toggle sign bit
G3:
	tst.l	d3			! check sign bit of second operand
	bpl 	G6			! ... and jump if not negative
	neg.l	d4			! negate 2nd half
	negx.l	d3			! negate first half
	bchg	#31,d3			! toggle sign bit
G6:
	cmp.l	d3,d1			! compare first halves of operands
	blt 	Glt
	bgt 	Ggt
	cmp.l	d4,d2			! equal - so compare second halves of operands
	bhi 	Ggt
	beq 	Geq

Glt:	moveq	#-1,d0
	movem.l (sp)+,d2-d4		! restore changed registers
	rts

Geq:	moveq	#0,d0
	movem.l (sp)+,d2-d4		! restore changed registers
	rts

Ggt:	moveq	#1,d0
	movem.l (sp)+,d2-d4		! restore changed registers
	rts

#endif /* GCC_MATH */

	END
