#
* C68 8 byte floating point divide routine
*-----------------------------------------------------------------------------
* ported to 68000 by Kai-Uwe Bloem, 12/89
*	   #1	   original author: Peter S. Housel 4/8/89,6/2/89,6/13/89
*	   #2	   added support for denormalized numbers				   -kub-, 01/90
*	   #3	   change loop criterion for division loop to have a 1 behind the implied
*	   1 position of result. This gives greater accuracy, especially when
*	   dealing with denormalized numbers (although there are now eventually
*	   8 bits which are no longer calculated - .norm8 uses 4 of them for
*	   rounding)											   -kub-, 01/90
*	   bugs:
*	   Division has only 4 rounding bits. There is no "sticky bit" information.
*	   Due to speed improvements the code is rather cryptic.
*	   #4	   Redid register usage, and then added wrapper routine
*	   to provide C68 IEEE compatibility	   Dave & Keith Walker 02/92
*	   #5	   Changed exit code to put pointer to result in D0   Dave Walker  12/92
*  #6  Changed entry/exit points so that these are now C68 compatible,
*	   Removed ACK entry points
*	   Changed error handling code													   -djw-   09/93
*  #7  Added support for hardware FPU support under QDOS	   -djw-   09/95
*  #8  Changed for new parameter format 					   -djw-   01/96
*	   (and to return result in d0/d1)
*  #9  Set d0/d1 when exiting with zero result				   -djw-   03/96
*  #10 Changes to support macroized assembler directives	   -djw-   02/97
*	   Changes to supported macroized  HW_FPU interface
*-----------------------------------------------------------------------------

#include "ieeeconf.h"

	SECTION text

	XDEF	.Ydfdiv
	XDEF	.Yasdfdiv

SAVEREG EQU 	 6*4			! size of saved registers on stack

*----------------------------------------
*		sp	Return address
*		sp+4	second operand
*		sp+12	first operand
*----------------------------------------
.Ydfdiv:
#ifdef HW_FPU
	FPU_CHECK
	bne	nofpu
*	FMOVE.D	4(sp),FP7		! move to FP register
	dc.w	0xf22f,0x5780,0x0004
*	FDIV.D	12(sp),FP7		! do multiply
	dc.w	0xf22f,0x57a0,0x000c
*	FMOVE.D	FP7,-(sp)		! push result onto stack
	dc.w	0xf227,0x7780
	FPU_RELEASE
	movem.l	(sp)+,d0/d1 		! pop result into d0/d1
	bra	divexit
nofpu:
#endif /* HW_FPU */
	movem.l	d2-d7,-(sp) 		! save registers
	movem.l	SAVEREG+12(sp),d4-d5	! load v
	lea	SAVEREG+4(sp),a1	! address of u (re-use area for result)
	movem.l	(a1),d6-d7		! load u
	bsr	dfdivide
	movem.l	(sp)+,d2-d7
divexit:
	move.l	(sp)+,a1		! get return address
	lea	16(sp),sp		! tidy stack ( 2 x double)
	jmp	(a1)			! ... and return

*----------------------------------------
*		sp	Return address
*		sp+4	address of result/first operand
*		sp+8	address of second operand
*----------------------------------------
.Yasdfdiv:
#ifdef HW_FPU
	FPU_CHECK
	bne	nofpu2
	move.l	4(sp),a1		! get address for result/dividend
*	FMOVE.D	(a1),FP7		! load multiplicand into FP register
	dc.w	0xf211,0x5780
*	FDIV.D	8(sp),FP7		! do multiply
	dc.w	0xf22f,0x57a0,0x0008
*	FMOVE.D	FP7,(a1)		! store result
	dc.w	0xf211,0x7780
	FPU_RELEASE
	movem.l	(a1),d0/d1		! load result into d0/d1
	bra	asexit
nofpu2:
#endif /* HW_FPU */
	movem.l	d2-d7,-(sp) 		! save registers
	movem.l	SAVEREG+8(sp),d4-d5	! load v
	move.l	SAVEREG+4(sp),a1	! address of u / result address
	movem.l	(a1),d6-d7		! load u
	bsr	dfdivide
	movem.l	(sp)+,d2-d7
asexit:
	move.l	(sp)+,a1		! get return address
	lea	12(sp),sp		! tidy stack ( address + double)
	jmp	(a1)			! ... and return

*-------------------------------------------------------------------------
* This is the routine that actually carries out the operation.
*
* Register usage:
*
*			Entry				Exit
*
*	   d0		?				undefined
*	   d1		?				undefined
*	   d2		?				undefined
*	   d3		?				undefined
*	   d4-d5	v				undefined
*	   d6-d7	u				undefined
*
*	   A1		Address for result		preserved
*
*-----------------------------------------------------------------------------

dfdivide:
	move.l	d6,d0			! d0 = u.exp
	swap	d0
	move.w	d0,d2			! d2 = u.sign

	move.l	d4,d1			! d1 = v.exp
	swap	d1
	eor.w	d1,d2			! d2 = u.sign ^ v.sign (in bit 31)

	and.l	#0x0fffff,d6		! remove exponent from u.mantissa
	lsr.w	#4,d0
	and.w	#0x07ff,d0		! kill sign bit
	beq	0f			! check for zero exponent - no leading "1"
	bset	#20,d6			! restore implied leading "1"
	bra	1f
0:	addq.w	#1,d0			! "normalize" exponent
1:	move.l	d6,d3
	or.l	d7,d3
	beq	retz			! dividing zero

	and.l	#0x0fffff,d4		! remove exponent from v.mantissa
	lsr.w	#4,d1
	and.w	#0x07ff,d1		! kill sign bit
	beq	0f			! check for zero exponent - no leading "1"
	bset	#20,d4			! restore implied leading "1"
	bra 	1f
0:	addq.w	#1,d1			! "normalize" exponent
1:	move.l	d4,d3
	or.l	d5,d3
	beq 	divz			! divide by zero

	move.w	d2,a0			! save sign

	sub.w	d1,d0			! subtract exponents,
	add.w	#BIAS8-11+1,d0		!  add bias back in, account for shift
	add.w	#66,d0			!  add loop offset, +2 for extra rounding bits
					!  for denormalized numbers (2 implied by dbra)
	move	#24,d1			! bit number for "implied" pos (+4 for rounding)
	moveq	#-1,d2			! zero the quotient
	moveq	#-1,d3			!  (for speed it is a one s complement)
	sub.l	d5,d7			! initial subtraction,
	subx.l	d4,d6			! u = u - v
2:
	btst	d1,d2			! divide until 1 in implied position
	beq	5f

	add.l	d7,d7
	addx.l	d6,d6
	bcs 4f				! if carry is set, add, else subtract

	addx.l	d3,d3			! shift quotient and set bit zero
	addx.l	d2,d2
	sub.l	d5,d7			! subtract
	subx.l	d4,d6			! u = u - v
	dbra	d0,2b			! give up if result is denormalized
	bra 5f
4:
	addx.l	d3,d3			! shift quotient and clear bit zero
	addx.l	d2,d2
	add.l	d5,d7			! add (restore)
	addx.l	d4,d6			! u = u + v
	dbra	d0,2b			! give up if result is denormalized
5:	subq.w	#2,d0			! remove rounding offset for denormalized nums
	not.l	d2			! invert quotient to get it right
	not.l	d3

	movem.l	d2-d3,(a1)		! save quotient mantissa
	move.w	a0,d2			! get sign back
	clr.w	d1			! zero rounding bits
	jmp 	.Xnorm8 		! exit via normalisation (a1 still points to result)


retz:	moveq	#0,d0			! set result to zero
	moveq	#0,d1
	bra 	exitz

divz:
	jsr 	.divzero		! call exception routine
exitz:
	movem.l	d0/d1,(a1)		! store result
	rts 				! ... and exit - no normalisation required

	END
