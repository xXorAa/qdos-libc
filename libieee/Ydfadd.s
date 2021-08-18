#
*  C68 8 byte floating point add/subtract routines.
*-----------------------------------------------------------------------------
* ported to 68000 by Kai-Uwe Bloem, 12/89
*  #1  original author: Peter S. Housel 9/21/88,01/17/89,03/19/89,5/24/89
*  #2  replaced shifts by swap if possible for speed increase  -kub-, 01/90
*  #3  Redid register usage, and then added wrapper routine
*	   to provide C68 IEEE compatibility		   Dave & Keith Walker 02/92
*  #4  Changed exit code to put pointer to result in D0   Dave Walker  12/92
*  #5  Changed entry point names for use with C68 v4.3
*	   Changed exit code to C68 v4.3 compatibility
*	   Removed ACK entry points.							   -djw-   09/93
*  #6  Added support for hardware FPU support under QDOS	   -djw-   12/95
*  #7  Changed to use revised parameter formats 			   -djw-   01/96
*  #8  Changes to support macroized assembler directives	   -djw-   02/97
*	   Changes to supported macroized  HW_FPU interface
*-----------------------------------------------------------------------------

#include "ieeeconf.h"

	SECTION text

	XDEF	.Ydfadd
	XDEF	.Ydfsub
	XDEF	.Yasdfadd
	XDEF	.Yasdfsub

	XREF	.Xnorm8

SAVEREG EQU 6*4 	  			! Size of saved registers on stack

*----------------------------------------
*	sp	Return address
*	sp+4	value of v
*	sp+12	value of u
*	result returnded in d0/d1
*----------------------------------------

.Ydfadd:
	moveq	#0,d1				! set for add
	bra	1f
.Ydfsub:
	moveq	#1,d1				! sign bit
	ror.l	#1,d1				! set for subtract
1:
#ifdef HW_FPU
	FPU_CHECK
	bne	nofpu
*	FMOVE.D	4(sp),FP7			! move value to FP register
	dc.w	0xf22f,0x5780,0004
	tst.l	d1				! is it a 'add'
	bne	3f				! ... NO, jump to subtract
*	FADD.D	12(sp),FP7			! ... YES do add
	dc.w	0xf22f,0x57a2,0x000c
	bra	4f
*	FSUB.D	12(sp),FP7
3:	dc.w	0xf22f,0x57a8,0x000c
*	FMOVE.D	FP7,-(sp)			! get result out of FP register
4:	dc.w	0xf227,0x7780
	FPU_RELEASE
	movem.l	(sp)+,d0/d1 			! move result into d0/d1
	bra 	addexit
nofpu:
#endif /* HW_FPU */
	movem.l	d2-d7,-(sp) 			! save registers
	movem.l	SAVEREG+12(sp),d4-d5		! load v
	lea	SAVEREG+4(sp),a1		! re-use parameter space for result area
	movem.l	(a1),d6-d7			! load u
	bsr	dfaddsub			! go to do operation
	movem.l	(sp)+,d2-d7 			! restore saved registers
addexit:
	move.l	(sp)+,a1			! get return address
	lea	16(sp),sp			! remove parameters from stack (2 doubles)
	jmp	(a1)				! ... and return


*----------------------------------------
*	sp	Return address
*	sp+4	address of result/v
*	sp+8	value of u
*	Result returned in d0/d1
*----------------------------------------

.Yasdfadd:
	moveq	#0,d1				! set for add
	bra	1f

.Yasdfsub:
	moveq	#1,d1				! sign bit
	ror.l	#1,d1				! set for subtract

1:
#ifdef HW_FPU
	FPU_CHECK
	bne	nofpu2
	move.l	4(sp),a1			! get address for result/ numerator
*	FMOVE.D	(a1),FP7
	dc.w	0xf211,0x5780
	tst.l	d1				! is it an 'add'
	bne	3f				! ... NO, jump
*	FADD.D	8(sp),FP7
	dc.w	0xf22f,0x57a2,0x0008
	bra	4f
*	FSUB.D	8(sp),FP7
3:	dc.w	0xf22f,0x57a8,0x0008
*	FMOVE.D	FP7,(a1)			! store result
4:	dc.w	0xf211,0x7780
	FPU_RELEASE
	movem.l	(a1),d0/d1			! put result into d0/d1
	bra	asexit
nofpu2:
#endif /* HW_FPU */
	movem.l	d2-d7,-(sp) 			! save registers
	movem.l	SAVEREG+8(sp),d4-d5		! load u
	move.l	SAVEREG+4(sp),a1		! address of v / result address
	movem.l	(a1),d6-d7			! ... load v
	bsr	dfaddsub			! go to do operation
	movem.l	(sp)+,d2-d7 			! restore saved registers
asexit:
	move.l	(sp)+,a1			! get return address
	lea	12(sp),sp			! remove parameters from stack (1 pointer, 1 double)
	jmp	(a1)				! ... and return

*-------------------------------------------------------------------------
* This is the routine that actually carries out the operation.
*
* Register usage:
*
*		Entry				Exit
*
*	d0	add/subtract mask		undefined
*	d1	?				undefined
*	d2	?				undefined
*	d3	?				undefined
*	d4-d5	v				undefined
*	d6-d7	u				undefined
*
*	A1	Address for result		preserved
*
*-----------------------------------------------------------------------------

dfaddsub:
	eor.l	d1,d4				! reverse sign of v if needed (frees d1 for use)
	move.l	d6,d0				! d0 = u.exp
	swap	d0
	move.l	d6,d2				! d2.h = u.sign
	move.w	d0,d2
	lsr.w	#4,d0
	and.w	#0x07ff,d0			! kill sign bit

	move.l	d4,d1				! d1 = v.exp
	swap	d1
	eor.w	d1,d2				! d2.l = u.sign ^ v.sign
	lsr.w	#4,d1
	and.w	#0x07ff,d1			! kill sign bit

	and.l	#0x0fffff,d6			! remove exponent from u.mantissa
	tst.w	d0					! check for zero exponent - no leading "1"
	beq	0f
	bset	#20,d6				! restore implied leading "1"
	bra	1f
0:	addq.w	#1,d0				! "normalize" exponent
1:
	and.l	#0x0fffff,d4			! remove exponent from v.mantissa
	tst.w	d1				! check for zero exponent - no leading "1"
	beq	0f
	bset	#20,d4				! restore implied leading "1"
	bra	1f
0:	addq.w	#1,d1				! "normalize" exponent
1:
	clr.w	d3				! (put initial zero rounding bits in d3)
	neg.w	d1				! d1 = u.exp - v.exp
	add.w	d0,d1
	beq	5f				! exponents are equal - no shifting neccessary
	bgt	1f				! not equal but no exchange neccessary
	exg	d4,d6				! exchange u and v
	exg	d5,d7
	sub.w	d1,d0				! d0 = u.exp - (u.exp - v.exp) = v.exp
	neg.w	d1
	tst.w	d2				! d2.h = u.sign ^ (u.sign ^ v.sign) = v.sign
	bpl	1f
	bchg	#31,d2
1:
	cmp.w	#53,d1				! is u so much bigger that v is not
	bge	7f				! significant ?

	move.w	#10-1,d3			! shift u left up to 10 bits to minimize loss
2:
	add.l	d7,d7
	addx.l	d6,d6
	subq.w	#1,d0				! decrement exponent
	subq.w	#1,d1				! done shifting altogether ?
	dbeq	d3,2b				! loop if still can shift u.mant more
	clr.w	d3
3:
	cmp.w	#16,d1				! see if fast rotate possible
	blt	4f
	or.b	d5,d3				! set rounding bits
	or.b	d2,d3
	sne	d2				! "sticky byte"
	move.w	d5,d3
	lsr.w	#8,d3
	move.w	d4,d5				! rotate by swapping register halfs
	swap	d5
	clr.w	d4
	swap	d4
	sub.w	#16,d1
	bra	3b
0:
	lsr.l	#1,d4				! shift v.mant right the rest of the way
	roxr.l	#1,d5				! to line it up with u.mant
	or.b	d3,d2				! set "sticky byte" if necessary
	roxr.w	#1,d3				! shift into rounding bits
4:	dbra	d1,0b				! loop
	and.b	#1,d2				! see if "sticky bit" should be set
	or.b	d2,d3
5:
	tst.w	d2				! are the signs equal ?
	bpl	6f				! yes, no negate necessary

	neg.b	d3				! negate rounding bits and v.mant
	neg.l	d5
	negx.l	d4
6:
	add.l	d5,d7				! u.mant = u.mant + v.mant
	addx.l	d4,d6
	bcs	7f				! need not negate
	tst.w	d2				! opposite signs ?
	bpl	7f				! do not need to negate result

	neg.b	d3				! negate rounding bits and u.mant
	neg.l	d7
	negx.l	d6
	not.l	d2				! switch sign
7:
	movem.l	d6-d7,(a1)			! move result on stack
	move.b	d3,d1				! put rounding bits in d1 for .norm8
	swap	d2					! put sign into d2
	jmp	.Xnorm8 			! exit via normalising routine

	END
