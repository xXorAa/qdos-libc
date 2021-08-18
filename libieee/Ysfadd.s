#
* C68 4 byte floating point add/subtract routines
*-----------------------------------------------------------------------------
*  Based on _dfadd.s
*
*  #1  Redid register usage, and then added wrapper routine
*	   to provide C68 IEEE compatibility	   Dave & Keith Walker	   02/92
*  #2  Changed exit code to put pointer to result in D0   Dave Walker  12/92
*  #3  Changed entry/exit code for C68 v4.3 compatibility
*	   Removed ACK entry points.									   09/93
*  #4  Added support for hardware FPU support under QDOS	   -djw-   12/95
*  #5  Changed to take new parameter formats				   -djw-   12/95
*  #6  Changes to support macroized assembler directives	   -djw-   02/97
*	   Changes to supported macroized  HW_FPU interface
*  #7  Fixed problem with assign variants in HW_FPU version    -djw-   03/98
*-----------------------------------------------------------------------------

#include "ieeeconf.h"

	SECTION text

	XDEF	.Ysfadd
	XDEF	.Ysfsub
	XDEF	.Yassfadd
	XDEF	.Yassfsub

SAVEREG EQU  4*4	 ! size of saved registers ons tack

*----------------------------------------
*	sp	Return address
*	sp+4	v
*	sp+8	u
*----------------------------------------
.Ysfadd:
	moveq	#0,d1
	bra	1f
.Ysfsub:
	moveq	#1,d1				! sign bit
	ror.l	#1,d1				! set for subtract
1:
#ifdef HW_FPU
	FPU_CHECK
	bne 	nofpu
*	FMOVE.S 4(sp),FP7			! move to FP register
	dc.w	0xf22f,0x4780,0x0004
	tst.l	d1				! is it a 'add'
	bne 	3f				! ... NO, jump to subtract
*	FADD.S	8(sp),FP7			! ... YES do add
	dc.w	0xf22f,0x47a2,0x0008
	bra 	4f
*	FSUB.S	8(sp),FP7			! do subtract
3:	dc.w	0xf22f,0x47a8,0x0008
4:
*	FMOVE.S FP7,-(sp)			! store result on stack
	dc.w	0xf227,0x6780
	FPU_RELEASE
	move.l	(sp)+,d0			! pop result into d0
	bra 	addexit
nofpu:
#endif /* HW_FPU */

	movem.l d2-d4/d6,-(sp)			! save registers that get corrupted
	move.l	SAVEREG+8(sp),d4		! load v
	lea 	SAVEREG+4(sp),a1		! address of u (reused as result area)
	move.l	(a1),d6 			! load u
	bsr 	sfaddsub
	movem.l (sp)+,d2-d4/d6			!  restore saved registers
addexit:
	move.l	(sp)+,a0			! get return address
	addq.l	#8,sp				! remove parameters from stack ( 2 x float)
	jmp (a0)				! ... and return


*----------------------------------------
*	sp	Return address
*	sp+4	address of result/v
*	sp+8	u
*----------------------------------------
.Yassfadd:
	moveq	#0,d1				! set for add
	bra	1f

.Yassfsub:
	moveq	#1,d1				! sign bit
	ror.l	#1,d1				! set for subtract
1:
#ifdef HW_FPU
	FPU_CHECK
	bne 	nofpu2
	move.l	4(sp),a1			! get address for result/ numerator
*	FMOVE.S (a1),FP7
	dc.w	0xf211,0x4780
	tst.l	d1				! is it an 'add'
	bne 	3f				! ... NO, jump
*	FADD.S	8(sp),FP7
	dc.w	0xf22f,0x47a2,0x0008
	bra 	4f
*	FSUB.S	8(sp),FP7
3:	dc.w	0xf22f,0x47a8,0x0008
*	FMOVE.S FP7,(a1)			! store result
4:	dc.w	0xf211,0x6780
	FPU_RELEASE
	move.l	(a1),d0 			! put result into d0
	bra 	asexit
nofpu2:
#endif /* HW_FPU */
	
	movem.l d2-d4/d6,-(sp)			! save registers that get corrupted
	move.l	SAVEREG+8(sp),d4		! load v
	move.l	SAVEREG+4(sp),a1		! address of result/u
	move.l	(a1),d6 			! load u
	bsr 	sfaddsub
	movem.l (sp)+,d2-d4/d6			! restore saved registers
asexit:
	move.l	(sp)+,a0			! get return address
	addq.l	#8,sp				! remove parameters from stack ( pointer + float)
	jmp 	(a0)				! ... and return

*-------------------------------------------------------------------------
* This is the routine that actually carries out the operation.
*
* Register usage:
*
*	   Entry			   Exit
*
*  d0  add/subtract mask	   undefined
*  d1  ?			   undefined
*  d2  ?			   undefined
*  d3  ?			   undefined
*  d4  v			   undefined
*  d6  u			   undefined
*  A1  Address for result	   preserved
*
*-----------------------------------------------------------------------------

sfaddsub:
	eor.l	d1,d4		! reverse sign of v if needed (frees d1 for use)
	move.l	d6,d0		! d0 = u.exp
	swap	d0
	move.l	d6,d2		! d2.h = u.sign
	move.w	d0,d2
	lsr.w	#7,d0		! get exponent in least significant bits
	and.w	#0x0ff,d0	! kill sign bit

	move.l	d4,d1		! d1 = v.exp
	swap	d1
	eor.w	d1,d2		! d2.l = u.sign ^ v.sign
	lsr.w	#7,d1
	and.w	#0x0ff,d1	! kill sign bit

	and.l	#0x07fffff,d6	! remove exponent from u.mantissa
	tst.w	d0		! check for zero exponent - no leading "1"
	beq	0f
	bset	#23,d6		! restore implied leading "1"
	bra	1f
0:	add.w	#1,d0		! "normalize" exponent
1:
	and.l	#0x07fffff,d4	! remove exponent from v.mantissa
	tst.w	d1		! check for zero exponent - no leading "1"
	beq	0f
	bset	#23,d4		! restore implied leading "1"
	bra	1f
0:	add.w	#1,d1		! "normalize" exponent
1:
	clr.w	d3		! (put initial zero rounding bits in d3)
	neg.w	d1		! d1 = u.exp - v.exp
	add.w	d0,d1
	beq	5f		! exponents are equal - no shifting neccessary
	bgt	1f		! not equal but no exchange neccessary
	exg	d4,d6		! exchange u and v
	sub.w	d1,d0		! d0 = u.exp - (u.exp - v.exp) = v.exp
	neg.w	d1
	tst.w	d2		! d2.h = u.sign ^ (u.sign ^ v.sign) = v.sign
	bpl	1f
	bchg	#31,d2
1:
	cmp.w	#24,d1		! is u so much bigger that v is not
	bge	7f		! significant ?

	move.w	#7-1,d3 	! shift u left up to 7 bits to minimize loss
2:
	add.l	d6,d6
	sub.w	#1,d0		! decrement exponent
	sub.w	#1,d1		! done shifting altogether ?
	dbeq	d3,2b		! loop if still can shift u.mant more
	clr.w	d3
3:
	cmp.w	#16,d1		! see if fast rotate possible
	blt	4f
	or.b	d2,d3
	sne	d2		! "sticky byte"
	clr.w	d4
	swap	d4
	sub.w	#16,d1
	bra	3b
0:
	lsr.l	#1,d4		! shift v.mant right the rest of the way
	or.b	d3,d2		! set "sticky byte" if necessary
	roxr.w	#1,d3		! shift into rounding bits
4:	dbra	d1,0b		! loop
	and.b	#1,d2		! see if "sticky bit" should be set
	or.b	d2,d3
5:
	tst.w	d2		! are the signs equal ?
	bpl	6f		! yes, no negate necessary

	neg.b	d3		! negate rounding bits and v.mant
	neg.l	d4
6:
	add.l	d4,d6
	bcs	7f		! need not negate
	tst.w	d2		! opposite signs ?
	bpl	7f		! do not need to negate result

	neg.b	d3		! negate rounding bits and u.mant
	neg.l	d6
	not.l	d2		! switch sign
7:
	move.l	d6,(a1) 	! move result on stack
	move.b	d3,d1		! put rounding bits in d1 for .norm4
	swap	d2		! put sign into d2
	jmp	.Xnorm4 	! exit via normalise routine

	END
