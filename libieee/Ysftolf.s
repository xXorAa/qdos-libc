#
* C68 4 byte floating point => 12 byte floating point conversion routine
*-----------------------------------------------------------------------------
*	#1	First version.	Based on
*	#1	original author: Peter S. Housel 06/03/89
*	#2	added support for denormalized numbers			-kub-, 01/90
*	#3	Redid register usage, and then added wrapper routine
*	to provide C68 IEEE compatibility	Dave & Keith Walker 02/92
*	#4	Changed entry/exit code for C68 compatibility
*		Removed ACK entry points								-djw-	09/93
*	#5	Changed for new parameter formats						-djw-	01/96
*		(and to return value in d0/d1)
*	#6	Changes to support macroized assembler directives		-djw-	02/97
*		Changes to supported macroized	HW_FPU interface
*-----------------------------------------------------------------------------

#include "ieeeconf.h"

#ifdef LONG_DOUBLE

	SECTION text

	XDEF   .Ysftolf

*----------------------------------------
*	sp		Return address
*	sp+4	float value
*----------------------------------------

.Ysftolf:
#ifdef HW_FPU
	FPU_CHECK
	bne 	nofpu
*	FMOVE.S 4(sp),FP7			! put float value into FPU
	dc.w	0xf22f,0x4780,0x0004
*	FMOVE.X FP7,-(sp)			! push double value from FPU
	dc.w	0xf227,0x6b80
	FPU_RELEASE
	movem.l (sp)+,d0/d1/d2			! pop long double value into d0/d1/d2
	bra 	finish
nofpu:
#endif /* HW_FPU */

	lea 	4(sp),a0			! value address
	lea 	-12(sp),sp			! reserve space for result
	move.l	sp,a1				! ... and set as target address
	move.l	(a0),(a1)			! move across value
	clr.l	4(a1)				! clear unset bits
	clr.l	8(a1)				! clear unset bits

	move.w	(a1),d0 			! extract exponent
	move.w	d0,d2				! extract sign
	lsr.w	#7,d0
	and.w	#0xff,d0			! kill sign bit (exponent is 8 bits)

	move.w	d2,d1
	and.w	#0x7f,d1			! remove exponent from mantissa
	tst.w	d0				! check for zero exponent - no leading "1"
	beq 	0f				! for denormalized numbers
	or.w	#0x80,d1			! restore implied leading "1"
	bra 1f
0:	add.w	#1,d0				! "normalize" exponent
1:	move.w	d1,(a1)

	add.w	#BIAS12-BIAS4-3,d0		! adjust bias, account for shift
	clr.w	d1				! dummy rounding info
	jsr 	.Xnorm12
	lea 	12(sp),sp			! remove work area

finish:
	move.l	(sp)+,a1			! get return address
	addq	#8,sp				! tidy stack (return address + float)
	jmp 	(a1)				! ... and return

#ifdef GCC_MATH_FULL

	XDEF   .GYsftolf

*----------------------------------------
*	sp		Return address
*	sp+4	float value
*----------------------------------------

.GYsftolf:
#ifdef HW_FPU
	FPU_CHECK
	bne 	Gnofpu
*	FMOVE.S 4(sp),FP7			! put float value into FPU
	dc.w	0xf22f,0x4780,0x0004
*	FMOVE.X FP7,-(sp)			! push double value from FPU
	dc.w	0xf227,0x6b80
	FPU_RELEASE
	movem.l (sp)+,d0/d1/d2			! pop long double value into d0/d1/d2
	rts
Gnofpu:
#endif /* HW_FPU */
	lea 	4(sp),a0			! value address
	lea 	-12(sp),sp			! reserve space for result
	move.l	sp,a1				! ... and set as target address
	move.l	(a0),(a1)			! move across value
	clr.l	4(a1)				! clear unset bits
	clr.l	8(a1)				! clear unset bits

	move.w	(a1),d0 			! extract exponent
	move.w	d0,d2				! extract sign
	lsr.w	#7,d0
	and.w	#0xff,d0			! kill sign bit (exponent is 8 bits)

	move.w	d2,d1
	and.w	#0x7f,d1			! remove exponent from mantissa
	tst.w	d0				! check for zero exponent - no leading "1"
	beq 	G0				! for denormalized numbers
	or.w	#0x80,d1			! restore implied leading "1"
	bra	G1
G0:	add.w	#1,d0				! "normalize" exponent
G1:	move.w	d1,(a1)

	add.w	#BIAS12-BIAS4-3,d0		! adjust bias, account for shift
	clr.w	d1				! dummy rounding info
	jsr 	.Xnorm12
	lea 	12(sp),sp			! remove work area
	rts

#endif /* GCC_MATH */

#endif /* LONG_DOUBLE */

	END
