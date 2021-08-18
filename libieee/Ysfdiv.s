#
* C68 4 byte floating point divide routine
*-----------------------------------------------------------------------------
* ported to 68000 by Kai-Uwe Bloem, 12/89
*  #1  original author: Peter S. Housel 4/8/89,6/2/89,6/13/89
*  #2  added support for denormalized numbers								   -kub-, 01/90
*  #3  change loop criterion for division loop to have a 1 behind the implied
*	   1 position of result. This gives greater accuracy, especially when
*	   dealing with denormalized numbers (although there are now eventually
*	   8 bits which are no longer calculated - .norm8 uses 4 of them for
*	   rounding)																							   -kub-, 01/90
*	   bugs:
*	   Division has only 4 rounding bits. There is no "sticky bit" information.
*	   Due to speed improvements the code is rather cryptic.
*  #4  Redid register usage, and then added wrapper routine
*	   to provide C68 IEEE compatibility					   Dave & Keith Walker 02/92
*  #5  Changed exit code to put pointer to result in D0   Dave Walker  12/92
*  #6  Changed entry/exit code for C68 v4.3 compatibility
*	   Removed ACK entry points.																			   09/93
*  #7  Added support for hardware FPU support under QDOS	   -djw-   09/95
*  #8  Changed for new parameter format 					   -djw-   01/96
*	   (and to return result in d0/d1)
*  #9  Set d0 when exiting with zero result 				   -djw-   03/96
*  #10 Changes to support macroized assembler directives	   -djw-   02/97
*	   Changes to supported macroized  HW_FPU interface
*-----------------------------------------------------------------------------

#include "ieeeconf.h"

	SECTION text

	XDEF	.Ysfdiv
	XDEF	.Yassfdiv

SAVEREG EQU 	  3*4	  ! offset of multiplicand

*----------------------------------------
*		sp		Return address
*		sp+4	second operand
*		sp+8	first operand
*----------------------------------------

.Ysfdiv:
#ifdef HW_FPU
	FPU_CHECK
	bne	nofpu
*	FMOVE.S	4(sp),FP7			! load top part
	dc.w	0xf22f,0x4780,0x0004
*	FDIV.S	8(sp),FP7			! do multiply
	dc.w	0xf22f,0x47a0,0x0008
*	FMOVE.S	FP7,-(sp)			! push result
	dc.w	0xf227,0x6780
	FPU_RELEASE
	move.l	(sp)+,d0			! pop result into d0
	bra	divexit
nofpu:
#endif /* HW_FPU */
	movem.l	d3/d4/d6,-(sp)			! save registers
	move.l	SAVEREG+8(sp),d4		! load v
	lea	SAVEREG+4(sp),a1		! address of u (re-use area for result)
	move.l	(a1),d6 			! load u
	bsr	sfdivide
	movem.l	(sp)+,d3/d4/d6			! restore saved registers
divexit:
	move.l	(sp)+,a1			! get return address
	addq.l	#8,sp				! tidy stack (address + float)
	jmp	(a1)				! ... and return

*----------------------------------------
*		sp		Return address
*		sp+4	address of result/first operand
*		sp+8	second operand
*----------------------------------------

.Yassfdiv:
#ifdef HW_FPU
	FPU_CHECK
	bne	nofpu2
	move.l	4(sp),a1			! get address for result/multiplicand
*	FMOVE.S	(a1),FP7			! load multiplicand into FP register
	dc.w	0xf211,0x4780
*	FDIV.S	8(sp),FP7			! do multiply
	dc.w	0xf22f,0x47a0,0x0008
*	FMOVE.S	FP7,(a1)			! store result
	dc.w	0xf211,0x6780
	move.l	(a1),-(sp)			! ... and save for later
	FPU_RELEASE
	move.l	(sp)+,d0			! load result into d0 as well
	bra	asexit
nofpu2:
#endif /* HW_FPU */
	movem.l	d3/d4/d6,-(sp)			! save registers
	move.l	SAVEREG+8(sp),d4		! load v
	move.l	SAVEREG+4(sp),a1		! address of u / result address
	move.l	(a1),d6 			! load u
	bsr	sfdivide			! do operation
	movem.l	(sp)+,d3/d4/d6			! restore saved registers
asexit:
	move.l	(sp)+,a0			! get return address
	addq.l	#8,sp				! tidy stack (address + float)
	jmp	(a0)				! ... and return

*-------------------------------------------------------------------------
* This is the routine that actually carries out the operation.
*
* Register usage:
*
*			   Entry						   Exit
*
*	   d0	   ?							   undefined
*	   d1	   ?							   undefined
*	   d2	   ?							   undefined
*	   d3	   ?							   undefined
*	   d4	   v							   undefined
*	   d6	   u							   undefined
*
*	   A1	   Address for result			   preserved
*
*-----------------------------------------------------------------------------

sfdivide:
	move.l	d6,d0				! d0 = u.exp
	swap	d0
	move.w	d0,d2				! d2 = u.sign

	move.l	d4,d1				! d1 = v.exp
	swap	d1
	eor.w	d1,d2				! d2 = u.sign ^ v.sign (in bit 31)

	and.l	#0x07fffff,d6			! remove exponent from u.mantissa
	lsr.w	#7,d0				! right justify exponent in word
	and.w	#0x0ff,d0			! kill sign bit
	beq	0f				! check for zero exponent - no leading "1"
	bset	#23,d6				! restore implied leading "1"
	bra	1f
0:	addq.w	#1,d0				! "normalize" exponent
1:	tst.l	d6				! zero ?
	beq	retz				! dividing zero

	and.l	#0x07fffff,d4			! remove exponent from v.mantissa
	lsr.w	#7,d1				! right justify exponent in word
	and.w	#0x0ff,d1			! kill sign bit
	beq	0f				! check for zero exponent - no leading "1"
	bset	#23,d4				! restore implied leading "1"
	bra	1f
0:	addq.w	#1,d1				! "normalize" exponent
1:	tst.l	d4
	beq	divz				! divide by zero

	sub.w	d1,d0				! subtract exponents,
	add.w	#BIAS4-8+1,d0			!  add bias back in, account for shift
	add.w	#32+2,d0			!  add loop offset, +2 for extra rounding bits
						!		for denormalized numbers (2 implied by dbra)
	moveq	#27,d1				! bit number for "implied" pos (+4 for rounding)
	moveq	#-1,d3				! zero the quotient 
						! (for speed it is a one s complement)
	sub.l	d4,d6				! initial subtraction, u = u - v
2:
	btst	d1,d3				! divide until 1 in implied position
	beq	5f

	add.l	d6,d6
	bcs	4f				! if carry is set, add, else subtract

	addx.l	d3,d3				! shift quotient and set bit zero
	sub.l	d4,d6				! subtract u = u - v
	dbra	d0,2b				! give up if result is denormalized
	bra	5f
4:
	addx.l	d3,d3				! shift quotient and clear bit zero
	add.l	d4,d6				! add (restore) u = u + v
	dbra	d0,2b				! give up if result is denormalized
5:	subq.w	#2,d0				! remove rounding offset for denormalized nums
	not.l	d3				! invert quotient to get it right

	move.l	d3,(a1) 			! save quotient mantissa
	clr.w	d1				! zero rounding bits
	jmp	.Xnorm4 			! exit via normalise (a1 still points to result)

retz:	moveq	#0,d0				! set zero as return value
	bra	exitz
divz:
	jsr	.divzero			! call xception routine
exitz:
	move.l	d0,(a1) 			! store result if control returned
	rts 					! exit - no normalisation needed

	END
