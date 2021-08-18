#
* C68 32 bit integer => 8 byte-floating point conversion routine
*-----------------------------------------------------------------------------
* ported to 68000 by Kai-Uwe Bloem, 12/89
*  #1  original author: Peter S. Housel 3/28/89
*  #2  Redid register usage, and then added wrapper routine
*	   to provide C68 IEEE compatibility		   Dave & Keith Walker 02/92
*  #3  Redid entry/exit points for C68 v4.3 compatibility
*	   Removed ACK entry points 							   -djw-   09/93
*  #4  Added support for hardware FPU support under QDOS	   -djw-   12/95
*  #5  Changed for new parameter format 					   -djw-   01/96
*	   (and to return result in d0/d1)
*  #6  Changes to support macroized assembler directives	   -djw-   02/97
*	   Changes to supported macroized  HW_FPU interface
*-----------------------------------------------------------------------------

#include "ieeeconf.h"

	SECTION text

	XDEF	.Ydfltodf

*----------------------------------------
*	sp		Return address
*	sp+4	value to convert
*----------------------------------------

.Ydfltodf:
#ifdef HW_FPU
	FPU_CHECK
	bne 	nofpu
*	FMOVE.L 4(sp),FP7			! load value into FPU
	dc.w	0xf22f,0x4380,0x0004
*	FMOVE.D FP7,-(sp)			! pop result onto stack
	dc.w	0xf227,0x7780
	FPU_RELEASE
	movem.l (sp)+,d0/d1 		! load result into d0/d1
	bra 	finish
nofpu:
#endif /* HW_FPU */
	move.l	4(sp),d1			! get the 4-byte integer
	move.w	#BIAS8+32-11,d0 		! radix point after 32 bits
	move.w	4(sp),d2			! get/check sign of number
	bge 	1f				! nonnegative
	neg.l	d1				! take absolute value
1:
	clr.l	-(sp)				! write mantissa onto stack (reserving area)
	move.l	d1,-(sp)
	move.l	sp,a1				! set a1 to point to result area
	clr.w	d1				! set rounding = 0
	jsr 	.Xnorm8
	addq.l	#8,sp				! remove work area from stack
finish:
	move.l	(sp)+,a1			! get return address
	addq.l	#4,sp				! tidy stack (double + return + long)
	jmp 	(a1)				! ... and return

	END
