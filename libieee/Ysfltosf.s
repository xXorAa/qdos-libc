#
* C68 32 bit integer => 4-byte-floating point conversion routine
*-----------------------------------------------------------------------------
* ported to 68000 by Kai-Uwe Bloem, 12/89
*  #1  original author: Peter S. Housel 3/28/89
*  #2  Redid register usage, and then added wrapper routine
*  to provide C68 IEEE compatibility   Dave & Keith Walker 02/92
*  #3  Changed entry/exit code for C68 v4.3 compatibility
*	   Removed ACk entry points 							   -djw-   09/93
*  #4  Added support for hardware FPU support under QDOS	   -djw-   12/95
*  #5  Changed for new parameter format 					   -djw-   01/96
*	   (and to return result in d0)
*	#6	Changes to support macroized assembler directives		-djw-	02/97
*		Changes to supported macroized	HW_FPU interface
*-----------------------------------------------------------------------------

#include "ieeeconf.h"

	SECTION text

	XDEF	.Ysfltosf

*---------------------------------------
*  sp  Return address
*  sp+4    value to convert
*---------------------------------------
.Ysfltosf:
#ifdef HW_FPU
	FPU_CHECK
	bne 	nofpu
*	FMOVE.L	4(sp),FP7
	dc.w	0xf22f,0x4380,0x0004
*	FMOVE.S	FP7,-(sp)			! push result onto stack
	dc.w	0xf227,0x6780
	FPU_RELEASE
	move.l	(sp)+,d0			! pop result into d0
	bra 	finish
nofpu:
#endif /* HW_FPU */
	lea 	4(sp),a1			! address for source (re-use for result area)
	move.l	(a1),d1 			! get the 4-byte integer
	move.w	#BIAS4+32-8,d0			! radix point after 32 bits
	move.w	(a1),d2 			! check sign of number
	bge 1f					! nonnegative
	neg.l	d1				! take absolute value
1:
	move.l	d1,(a1) 			! write mantissa onto stack
	clr.w	d1				! set rounding = 0
	jsr 	.Xnorm4
finish:
	move.l	(sp)+,a0			! get return address
	addq.l	#4,sp				! tidy stack ( 1 x long)
	jmp 	(a0)				! ... and return

	END
