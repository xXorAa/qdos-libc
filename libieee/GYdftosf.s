#
* C68 8 byte floating point => 4 byte floating point conversion routine
*-----------------------------------------------------------------------------
*  #1  Written from Ydftosf.s				Thierry Godefroy
*-----------------------------------------------------------------------------

#include "ieeeconf.h"

#ifdef GCC_MATH

	SECTION text

	XDEF	.GYdftosf

SAVEREG EQU 	3*4 		  ! size of saved registers on stack

*----------------------------------------
*	sp		Return address
*	sp+4	value of argument
*----------------------------------------
.GYdftosf:
#ifdef HW_FPU
	FPU_CHECK
	bne 	Gnofpu
*	FMOVE.D 4(sp),FP7			! argument value into FP register
	dc.w	0xf22f,0x5780,0x0004
*	FMOVE.S FP7,-(sp)			! get out of FP register onto stack
	dc.w	0xf227,0x6780
	FPU_RELEASE
	move.l	(sp)+,d0			! finally move result to return register
	rts
Gnofpu:
#endif /* HW_FPU */
	movem.l d2-d4,-(sp)			! save registers that will be corrupted
	lea.l	SAVEREG+4(sp),a1		! argument address (re-use for result)

	move.w	(a1),d0				! extract exponent
	move.w	d0,d2				! extract sign
	lsr.w	#4,d0
	and.w	#0x7ff,d0			! kill sign bit

	move.w	d2,d1
	and.w	#0x0f,d1			! remove exponent from mantissa
	tst.w	d0				! check for zero exponent - no leading "1"
	beq	G0				! for denormalized numbers
	or.w	#0x10,d1			! restore implied leading "1"
	bra	G1
G0:	addq.w	#1,d0				! "normalize" exponent
G1:	move.w	d1,d3				! store exponent
	swap	d3				! ... in correct part of register
	move.w	2(a1),d3			! get next 2 bytes of original value
	move.l	4(a1),d4			! .. and the last 4 bytes

	add.w	#BIAS4-BIAS8,d0 		! adjust bias

	add.l	d4,d4				! shift up to realign mantissa for floats
	addx.l	d3,d3
	add.l	d4,d4
	addx.l	d3,d3
	add.l	d4,d4
	addx.l	d3,d3
	move.l	d3,(a1)				! write result.mantissa

	move.l	d4,d1				! set rounding bits
	rol.l	#8,d1
	and.l	#0x00ffffff,d4			! check to see if sticky bit should be set
	beq	G2
	or.b	#1,d1				! set sticky bit
G2:	jsr	.Xnorm4				! go to normalise result

	movem.l (sp)+,d2-d4			! restore saved registers
	rts

#endif /* GCC_MATH */

	END
