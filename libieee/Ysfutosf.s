#
/* C68 32 bit unsigned => 4-byte-floating point conversion routine
-----------------------------------------------------------------------------
ported to 68000 by Kai-Uwe Bloem, 12/89
   #1  original author: Peter S. Housel 3/28/89
   #2  Redid register usage, and then added wrapper routine
	   to provide C68 IEEE compatibility		   Dave & Keith Walker 02/92
   #3  Changed entry/exit code for C68 v4.3 compatibility
	   Removed ACK entry point					   09/93
   #4  Changed for new parameter format 					   -djw-   01/96
	   (and to return result in d0)
  #5  Changed to allow directive types to be set			   DJW	  02/97
----------------------------------------------------------------------------*/

#include "ieeeconf.h"

	SECTION text

	XDEF	.Ysfutosf

/* ----------------------------------------
   sp	   Return address
   sp+4    Value to convert
   ----------------------------------------*/

.Ysfutosf:
	lea.l	4(sp),a1			! address of value to convert (reuse area for result)
	move.l	(a1),d1 			! value to convert

	move.w	#BIAS4+32-8,d0			! radix point after 32 bits
	clr.w	d2				! sign is always positive
	move.l	d1,(a1) 			! write mantissa onto stack
	clr.w	d1				! set rounding = 0
	jsr 	.Xnorm4

	move.l	(sp)+,a0			! get return address
	addq.l	#4,sp				! tidy stack ( 1 x ulong)
	jmp 	(a0)				! ... and return

#ifdef GCC_MATH_FULL

	XDEF	.GYsfutosf

/* ----------------------------------------
   sp	   Return address
   sp+4    Value to convert
   ----------------------------------------*/

.GYsfutosf:
	lea.l	4(sp),a1			! address of value to convert (reuse area for result)
	move.l	(a1),d1 			! value to convert

	move.w	#BIAS4+32-8,d0			! radix point after 32 bits
	clr.w	d2				! sign is always positive
	move.l	d1,(a1) 			! write mantissa onto stack
	clr.w	d1				! set rounding = 0
	jsr 	.Xnorm4
	rts

#endif /* GCC_MATH */

	END
