#
*  c68 8 byte floating point negate routine
*-----------------------------------------------------------------------------
* ported to 68000 by Kai-Uwe Bloem, 12/89
*  #1  original author: Peter S. Housel
*  #2  Added routine to provide C68 IEEE compatibility
*												   Dave & Keith Walker 02/92
*  #3  Changed entry/exit code for C68 v4.3 compatibility
*	   Removed ACK entry points 							   -djw-   09/93
*  #4  Changed for new C68 parameter formats				   -djw-   01/96
*	   (and to return result in d0/d1)
*  #5  Changes to support macroized assembler directives	   -djw-   02/97
*-----------------------------------------------------------------------------

#include "ieeeconf.h"

	SECTION text

	XDEF	.Ydfneg

*----------------------------------------
*	sp		Return address
*	sp+4	value to negate
*----------------------------------------

.Ydfneg:
	movem.l 4(sp),d0/d1 ! load value into d0/d1
	tst.l	d1			! test second half
	bne 	negate		! We must negate if non-zero
	tst.l	d0			! Test for 0 in first part
	beq 	finish		! skip negate if also zero
negate:
	bchg	#31,d0		! flip sign bit

finish:
	move.l	(sp)+,a0	! get return address
	addq.l	#8,sp		! tidy stack (1 x double)
	jmp 	(a0)		! return

#ifdef GCC_MATH_FULL

	XDEF	.GYdfneg

*----------------------------------------
*	sp		Return address
*	sp+4	value to negate
*----------------------------------------

.GYdfneg:
	movem.l 4(sp),d0/d1 		! load value into d0/d1
	tst.l	d1			! test second half
	bne 	Gnegate			! We must negate if non-zero
	tst.l	d0			! Test for 0 in first part
	bne 	Gnegate			! negate if not zero
	rts
Gnegate:
	bchg	#31,d0			! flip sign bit
	rts

#endif /* GCC_MATH */

	END
