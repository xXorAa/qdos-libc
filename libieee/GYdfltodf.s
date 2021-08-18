#
* C68 32 bit integer => 8 byte-floating point conversion routine
*-----------------------------------------------------------------------------
*  #1  Written from Ydfltodf.s				Thierry Godefroy
*-----------------------------------------------------------------------------

#include "ieeeconf.h"

#ifdef GCC_MATH

	SECTION text

	XDEF	.GYdfltodf

*----------------------------------------
*	sp		Return address
*	sp+4	value to convert
*----------------------------------------

.GYdfltodf:
#ifdef HW_FPU
	FPU_CHECK
	bne 	Gnofpu
*	FMOVE.L 4(sp),FP7			! load value into FPU
	dc.w	0xf22f,0x4380,0x0004
*	FMOVE.D FP7,-(sp)			! pop result onto stack
	dc.w	0xf227,0x7780
	FPU_RELEASE
	movem.l (sp)+,d0/d1 			! load result into d0/d1
	rts
Gnofpu:
#endif /* HW_FPU */
	move.l	4(sp),d1			! get the 4-byte integer
	move.w	#BIAS8+32-11,d0 		! radix point after 32 bits
	move.w	4(sp),d2			! get/check sign of number
	bge 	G1				! nonnegative
	neg.l	d1				! take absolute value
G1:
	clr.l	-(sp)				! write mantissa onto stack (reserving area)
	move.l	d1,-(sp)
	move.l	sp,a1				! set a1 to point to result area
	clr.w	d1				! set rounding = 0
	jsr 	.Xnorm8
	addq.l	#8,sp				! remove work area from stack
	rts

#endif /* GCC_MATH */

	END
