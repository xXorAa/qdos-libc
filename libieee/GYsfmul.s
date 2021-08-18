#
* C68 4 byte floating point multiply routine
*-----------------------------------------------------------------------------
* #1	Written from Ysfmul.s				Thierry Godefroy
*-----------------------------------------------------------------------------

#include "ieeeconf.h"

#ifdef GCC_MATH

	SECTION text

	XDEF	.GYsfmul
	XDEF	.GYassfmul

SAVEREG EQU 	5*4 	! size of saved registers on stack

*----------------------------------------
*		sp	Return address
*		sp+4	float multiplicand
*		sp+8	float multiplier
*----------------------------------------
.GYsfmul:
#ifdef HW_FPU
	FPU_CHECK
	bne	Gnofpu
*	FMOVE.S	4(sp),FP7			! move to FP register
	dc.w	0xf22f,0x4780,0x0004
*	FMUL.S	8(sp),FP7			! do multiply
	dc.w	0xf22f,0x47a3,0x0008
*	FMOVE.S	FP7,-(sp)			! extract result onto stack
	dc.w	0xf227,0x6780
	FPU_RELEASE 				! release FPU
	move.l	(sp)+,d0			! pop result into d0
	rts
Gnofpu:
#endif	/* HW_FPU */
	movem.l	d2-d6,-(sp) 			! save registers
	move.l	SAVEREG+8(sp),d4		! load u
	lea	SAVEREG+4(sp),a1		! address of v (re-used as result area)
	move.l	(a1),d6 			! load v
	bsr	sfmultiply			! do operation
	movem.l	(sp)+,d2-d6 			! restore saved registers
	rts

*----------------------------------------
*		sp	Return address
*		sp+4	address of float result/multiplicand
*		sp+8	float multiplier
*----------------------------------------
.GYassfmul:
#ifdef HW_FPU
	FPU_CHECK
	bne	Gnofpu2
	move.l	4(sp),a1			! get address for result/multiplicand
*	FMOVE.S	(a1),FP7			! load multiplicand into FP register
	dc.w	0xf211,0x4780
*	FMUL.S	8(sp),FP7			! do multiply
	dc.w	0xf22f,0x47a3,0x0008
*	FMOVE.S	FP7,(a1)			! store result
	dc.w	0xf211,0x6780
	FPU_RELEASE 				! release FPU
	move.l	(a1),d0 			! put result into d0 as well
	rts
Gnofpu2:
#endif /* HW_FPU */
	movem.l	d2-d6,-(sp) 			! save registers
	move.l	SAVEREG+8(sp),d4		! load v
	move.l	SAVEREG+4(sp),a1		! address of u / result area
	move.l	(a1),d6 				! load u
	bsr	sfmultiply
	movem.l	(sp)+,d2-d6 			! restore saved registers
	rts

*-------------------------------------------------------------------------
* This is the routine that actually carries out the operation.
*
* Register usage:
*
*				Entry				Exit
*
*		d0		?				undefined
*		d1		?				undefined
*		d2		?				undefined
*		d3		?				undefined
*		d4		v (multiplicand)		undefined
*		d5		?				undefined
*		d6		u (multiplier)			undefined
*
*		A1		Address for result		preserved
*
*-----------------------------------------------------------------------------

sfmultiply:
	move.l	d6,d0				! d0 = u.exp
	swap	d0
	move.w	d0,d2				! d2 = u.sign

	move.l	d4,d1				! d1 = v.exp
	swap	d1
	eor.w	d1,d2				! d2 = u.sign ^ v.sign (in bit 31)

	and.l	#0x07fffff,d6			! remove exponent from u.mantissa
	lsr.w	#7,d0
	and.w	#0x0ff,d0			! kill sign bit
	beq	0f				! check for zero exponent - no leading "1"
	bset	#23,d6				! restore implied leading "1"
	bra	1f
0:	addq.w	#1,d0				! "normalize" exponent
1:	tst.l	d6				! multiplying by zero ?
	beq	retz				! ... yes - special case - take fast route

	and.l	#0x07fffff,d4			! remove exponent from v.mantissa
	lsr.w	#7,d1
	and.w	#0x0ff,d1			! kill sign bit
	beq	0f				! check for zero exponent - no leading "1"
	bset	#23,d4				! restore implied leading "1"
	bra	1f
0:	addq.w	#1,d1				! "normalize" exponent
1:	tst.l	d4				! multiplying by zero ?
	beq	retz				! ... yes - special case - take fast route

	add.w	d1,d0				! add exponents,
	sub.w	#BIAS4+8,d0 			! remove excess bias, acnt for repositioning

*	Now do a 32bit x 32bit multiply to get a 64 bit result
*	see Knuth, Seminumerical Algorithms, section 4.3. algorithm M

	subq.l	#8,sp				! reserve space on stack
	clr.l	(sp)				! initialize 64-bit product to zero
	clr.l	4(sp)
	lea	4(sp),a0			! address of 2nd half
	move.w	#2-1,d5
1:
	move.w	d4,d3
	mulu	d6,d3				! multiply with digit from multiplier
	move.l	(a0),d1 			! add to result
	addx.l	d3,d1
	move.l	d1,(a0)
#ifdef AS68
	roxl	-(a0)
#else
	roxl.w	#1,-(a0)			! rotate carry in
#endif

	move.l	d4,d3
	swap	d3
	mulu	d6,d3
	move.l	(a0),d1 			! add to result
	addx.l	d3,d1
	move.l	d1,(a0)

	swap	d6				! get next 16 bits of multiplier
	dbra	d5,1b

*	The next bit of code does a coarse normalisation to ensure that
*	we have enough bits to complete it in the .norm4 routine.

	movem.l	2(sp),d4/d5 ! get the 64 valid bits
2:
	cmp.l	#0x007fffff,d4			! multiply (shift) until
	bhi	3f				!  1 in upper result bits
	cmp.w	#9,d0				! give up for denormalized numbers
	ble	3f
	lsl.l	#8,d4				! else rotate up by 8 bits
	rol.l	#8,d5				! get 8 bits from d6
	move.b	d5,d4				! ... and insert into space
	clr.b	d5				! ... and then remove bits from running result
	subq.w	#8,d0				! reduce exponent
	bra	2b				! try again
3:
	move.l	d5,d1
	rol.l	#8,d1
	move.l	d1,d3				! see if sticky bit should be set
	and.l	#0xffffff00,d3
	beq 	5f
	or.b	#1,d1				! set "sticky bit" if any low-order set
5:
	addq.l	#8,sp				! remove stack workspace
	move.l	d4,(a1) 			! save result
	jmp	.Xnorm4 			! exit via normalisation routine

retz:	moveq	#0,d0				! set zero as return value
	move.l	d0,(a1) 			! ... and save in result area
	rts 					! no normalization needed

#endif /* GCC_MATH */

	END
