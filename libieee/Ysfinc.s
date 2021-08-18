#
* C68 4 byte floating point auto increment/decrement routine
*-----------------------------------------------------------------------------
*  #1  First version.									 Dave Walker   01/96
*  #2  Changes to support macroized assembler directives	   -djw-   02/97
*-----------------------------------------------------------------------------

#include "ieeeconf.h"

	SECTION text

	XDEF	.Ysfinc
	XDEF	.Ysfdec
	XDEF	__SFone

	XREF	.Yassfadd

__SFone:
	dc.l	0x3f800000

*-------------------------------------------
*	   sp	   Return address
*	   sp+4    pointer to value to increment
*-------------------------------------------
.Ysfinc:
	moveq	#0,d0					! set for sign bit clear
	bra 	shared

.Ysfdec:
	moveq	#1,d0					! set for sign bit set

shared:
	ror.l	#1,d0					! set sign bit if needed
	or.l	__SFone(pc),d0				! add in double constant
	move.l	4(sp),a1				! get address for value/result
	move.l	(a1),-(sp)				! push original value
	move.l	d0,-(sp)				! value to add
	move.l	a1,-(sp)				! result pointer
	jsr 	.Yassfadd
	move.l	(sp)+,d0				! pop original value as return value

	move.l	(sp)+,a1				! get return address
	addq	#4,sp					! tidy stack (1 x pointer)
	jmp 	(a1)

#ifdef GCC_MATH_FULL

	XDEF	.GYsfinc
	XDEF	.GYsfdec

*-------------------------------------------
*	   sp	   Return address
*	   sp+4    pointer to value to increment
*-------------------------------------------
.GYsfinc:
	moveq	#0,d0					! set for sign bit clear
	bra 	Gshared

.GYsfdec:
	moveq	#1,d0					! set for sign bit set

Gshared:
	ror.l	#1,d0					! set sign bit if needed
	or.l	__SFone(pc),d0				! add in double constant
	move.l	4(sp),a1				! get address for value/result
	move.l	(a1),-(sp)				! push original value
	move.l	d0,-(sp)				! value to add
	move.l	a1,-(sp)				! result pointer
	jsr 	.Yassfadd
	move.l	(sp)+,d0				! pop original value as return value
	rts

#endif /* GCC_MATH */

	END
