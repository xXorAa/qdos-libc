#
*  C68 12 byte floating point routine to test for zero
*-----------------------------------------------------------------------------
*  #1  First version based on 8 byte Ydftst_s	   Dave Walker		 12/92
*  #2  Changes to support macroized assembler directives	   -djw-   02/97
*-----------------------------------------------------------------------------																				  

#include "ieeeconf.h"

#ifdef LONG_DOUBLE

	SECTION text

	XDEF	.Xlftst

.Xlftst:
	move.l	(sp)+,a0		! get return address
	move.l	(sp)+,d0		! first 4 bytes
	or.l	(sp)+,d0		! 2nd 4 bytes
	or.l	(sp)+,d0		! 3rd 4 bytes
	jmp 	(a0)			! return

#ifdef GCC_MATH_FULL

	XDEF	.GXlftst

.GXlftst:
	move.l	4(sp),d0		! first 4 bytes
	or.l	8(sp),d0		! 2nd 4 bytes
	or.l	12(sp),d0		! 3rd 4 bytes
	rts				! return

#endif /* GCC_MATH */

#endif /* LONG_DOUBLE */

	END
