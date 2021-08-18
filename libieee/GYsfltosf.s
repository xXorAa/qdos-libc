#
* C68 32 bit integer => 4-byte-floating point conversion routine
*-----------------------------------------------------------------------------
*  #1  Written from Ysfltosf.s				Thierry Godefroy
*-----------------------------------------------------------------------------

#include "ieeeconf.h"

#ifdef GCC_MATH

	SECTION text

	XDEF	.GYsfltosf

*---------------------------------------
*  sp		Return address
*  sp+4		value to convert
*---------------------------------------
.GYsfltosf:
#ifdef HW_FPU
	FPU_CHECK
	bne 	Gnofpu
*	FMOVE.L	4(sp),FP7
	dc.w	0xf22f,0x4380,0x0004
*	FMOVE.S	FP7,-(sp)			! push result onto stack
	dc.w	0xf227,0x6780
	FPU_RELEASE
	move.l	(sp)+,d0			! pop result into d0
	rts
Gnofpu:
#endif /* HW_FPU */
	lea 	4(sp),a1			! address for source (re-use for result area)
	move.l	(a1),d1 			! get the 4-byte integer
	move.w	#BIAS4+32-8,d0			! radix point after 32 bits
	move.w	(a1),d2 			! check sign of number
	bge	G1				! nonnegative
	neg.l	d1				! take absolute value
G1:
	move.l	d1,(a1) 			! write mantissa onto stack
	clr.w	d1				! set rounding = 0
	jmp 	.Xnorm4

#endif /* GCC_MATH */

	END
