#
* 8 byte floating point multiply routine
*-----------------------------------------------------------------------------
* ported to 68000 by Kai-Uwe Bloem, 12/89
*  #1  original author: Peter S. Housel 4/1/89
*  #2  replace duplicated code by loop. Costs a little more time, but saves
*	   a lot of code. The time loss is minor due to the durance of a mulu
*	   instruction. 										   -kub-, 01/90
*  #3  added support for denormalized numbers				   -kub-, 01/90
*  #4  Redid register usage, and then added wrapper routine
*	   to provide C68 IEEE compatibility	   Dave & Keith Walker	   02/92
*  #5  Changed exit code to put pointer to result in D0   Dave Walker  12/92
*  #6  Added support for hardware FPU support under QDOS	   -djw-   09/95
*  #7  Changed to new parameter format						   -djw-   01/96
*	   (and to return result in d0/d1)
*  #8  Set d0/d1 on zero result exit						   -djw-   03/96
*  #9  Changes to support macroized assembler directives	   -djw-   02/97
*	   Changes to supported macroized  HW_FPU interface
*-----------------------------------------------------------------------------

#include "ieeeconf.h"

	SECTION text

	XDEF	.Ydfmul
	XDEF	.Yasdfmul


SAVEREG EQU 	 6*4				! size of saved registers on stack

*----------------------------------------
*		sp	Return address
*		sp+4	multiplicand
*		sp+12	multiplier
*----------------------------------------

.Ydfmul:
#ifdef HW_FPU
	FPU_CHECK
	bne 	nofpu
*	FMOVE.D 4(sp),FP7			! move to FP register
	dc.w	0xf22f,0x5780,0x0004
*	FMUL.D	12(sp),FP7			! do multiply
	dc.w	0xf22f,0x57a3,0x000c
*	FMOVE.D FP7,-(sp)			! push result
	dc.w	0xf227,0x7780
	FPU_RELEASE
	movem.l (sp)+,d0/d1 			! pop result into d0/d1
	bra 	mulexit
nofpu:
#endif	/* HW_FPU */
	movem.l d2-d7,-(sp) 			! save registers
	movem.l SAVEREG+12(sp),d4-d5		! load u
	lea 	SAVEREG+4(sp),a1		! address of v (re-used for result area)
	movem.l (a1),d6-d7			! load v
	bsr 	dfmultiply			! do operation
	movem.l (sp)+,d2-d7			! restore saved registers

mulexit:
	move.l	(sp)+,a1			! get return address
	lea 	16(sp),sp			! remove parameters from stack ( 2 x double)
	jmp 	(a1)				! ... and return

*----------------------------------------
*		sp		Return address
*		sp+4	address of result/multiplicand
*		sp+8	multiplier
*----------------------------------------
.Yasdfmul:
#ifdef HW_FPU
	FPU_CHECK
	bne 	nofpu2
	move.l	4(sp),a1			! get address for result/multiplicand
*	FMOVE.D (a1),FP7			! load multiplicand into FP register
	dc.w	0xf211,0x5780
*	FMUL.D	8(sp),FP7			! do multiply
	dc.w	0xf22f,0x57a3,0x0008
*	FMOVE.D FP7,(a1)			! store result
	dc.w	0xf211,0x7780
	FPU_RELEASE
	movem.l (a1),d0/d1			! load result into d0/d1
	bra 	asexit
nofpu2:
#endif /* HW_FPU */
	movem.l d2-d7,-(sp)			! save registers
	movem.l SAVEREG+8(sp),d4-d5 ! load u
	move.l	SAVEREG+4(sp),a1		! address of v / address of result
	movem.l (a1),d6-d7			! load v
	bsr 	dfmultiply
	movem.l (sp)+,d2-d7 			! restore saved registers

asexit:
	move.l	(sp)+,a1			! get return address
	lea 	12(sp),sp			! remove parameters from stack ( address + double)
	jmp 	(a1)				! ... and return

*-------------------------------------------------------------------------
* This is the routine that actually carries out the operation.
*
* Register usage:
*
*			Entry				Exit
*
*	   d0		?				} result
*	   d1		?				}
*	   d2		?				undefined
*	   d3		?				undefined
*	   d4-d5	v				undefined
*	   d6-d7	u				undefined
*
*	   A1		Address for result		preserved
*
*-----------------------------------------------------------------------------

dfmultiply:
	move.l	d6,d0				! d0 = u.exp
	swap	d0
	move.w	d0,d2				! d2 = u.sign

	move.l	d4,d1				! d1 = v.exp
	swap	d1
	eor.w	d1,d2				! d2 = u.sign ^ v.sign (in bit 31)

	and.l	#0x0fffff,d6			! remove exponent from u.mantissa
	lsr.w	#4,d0
	and.w	#0x07ff,d0			! kill sign bit
	beq	0f				! check for zero exponent - no leading "1"
	bset	#20,d6				! restore implied leading "1"
	bra	1f
0:	addq.w	#1,d0				! "normalize" exponent
1:	move.l	d6,d3
	or.l	d7,d3
	beq	retz				! multiplying by zero

	and.l	#0x0fffff,d4			! remove exponent from v.mantissa
	lsr.w	#4,d1
	and.w	#0x07ff,d1			! kill sign bit
	beq	0f				! check for zero exponent - no leading "1"
	bset	#20,d4				! restore implied leading "1"
	bra	1f
0:	addq.w	#1,d1				! "normalize" exponent
1:	move.l	d4,d3
	or.l	d5,d3
	beq	retz				! multiplying by zero

	add.w	d1,d0				! add exponents,
	sub.w	#BIAS8+5,d0			! remove excess bias, acnt for repositioning

*	Now do a 64bit x 64bit multiply to get a 128 bit result
*	see Knuth, Seminumerical Algorithms, section 4.3. algorithm M

	subq.l	#8,sp				! reserve space on stac
	subq.l	#8,sp
	clr.l	(sp)				! initialize 128-bit product to zero
	clr.l	4(sp)
	clr.l	8(sp)
	clr.l	12(sp)
	lea	8(sp),a0			! address of 2nd half

	swap	d2
	move.w	#4-1,d2
1:
	move.w	d5,d3
	mulu	d7,d3				! multiply with digit from multiplier
	add.l	d3,4(a0)			! store into result
	move.w	d4,d3
	mulu	d7,d3
	move.l	(a0),d1 			! add to result
	addx.l	d3,d1
	move.l	d1,(a0)
#if QDOS
	move.w	-(a0),d3
	roxl.w	#1,d3				! QDOS assembler does not do other form of ROXL
	move.w	d3,(a0)
#else
	roxl.w	#1,-(a0)			! rotate carry in
#endif

	move.l	d5,d3
	swap	d3
	mulu	d7,d3
	add.l	d3,4(a0)			! add to result
	move.l	d4,d3
	swap	d3
	mulu	d7,d3
	move.l	(a0),d1 			! add to result
	addx.l	d3,d1
	move.l	d1,(a0)

	move.w	d6,d7
	swap	d6
	swap	d7
	dbra	d2,1b

*	addq.w	#8,a0				! [TOP 16 BITS SHOULD BE ZERO !]
	swap	d2

	movem.l	2(sp),d4-d7			! get the 112 valid bits
	clr.w	d7				! (pad to 128)
2:
	cmp.l	#0x0000ffff,d4			! multiply (shift) until
	bhi	3f				!  1 in upper 16 result bits
	cmp.w	#9,d0				! give up for denormalized numbers
	ble	3f
	swap	d4				! (we are getting here only when multiplying
	swap	d5				!  with a denormalized number; there is an
	swap	d6				!  eventual loss of 4 bits in the rounding
	swap	d7				!  byte -- what a pity 8-)
	move.w	d5,d4
	move.w	d6,d5
	move.w	d7,d6
	clr.w	d7
	sub.w	#16,d0				! decrement exponent
	bra	2b
3:
	move.l	d6,d1				! get rounding bits
	rol.l	#8,d1
	move.l	d1,d3				! see if sticky bit should be set
	or.l	d7,d3				! (lower 16 bits of d7 are guaranteed to be 0)
	and.l	#0xffffff00,d3
	beq	4f
	or.b	#1,d1				! set "sticky bit" if any low-order set
4:
	addq.l	#8,sp				! remove stack workspace
	addq.l	#8,sp
	movem.l	d4-d5,(a1)			! save result
	jmp	.Xnorm8 			! exit via normalise routine

retz:	moveq	#0,d0				! set result to return
	moveq	#0,d1
	movem.l	d0/d1,(a1)			! ... and store at target location as well
	rts 					! no normalization needed

	END
