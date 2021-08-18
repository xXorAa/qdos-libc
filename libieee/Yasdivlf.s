#
* C68 /= support where right hand side 'long double'
*				  and left hand side is integral type
*-----------------------------------------------------------------------------
*  #1  First version:	 David J. Walker							   01/96
*  #2  Changes to support macroized assembler directives	   -djw-   02/97
*-----------------------------------------------------------------------------
*
*  Name:	   .Yasdivlf
*
*  This is just a wrapper around the shared '.Yasoplf' routine
*---------------------------------------------------------------------------

#ifdef LONG_DOUBLE

#include "ieeeconf.h"

	SECTION .text

	XDEF	.Yasdivlf

	XREF	.Ylfdiv
	XREF	.Yasoplf

.Yasdivlf:

	move.l	(sp)+,d0				! pop current return address
	pea 	.Ylfdiv 				! operation wanted
	move.l	d0,-(sp)				! push back return address
	jmp 	.Yasoplf

#ifdef GCC_MATH_FULL

	XDEF	.GYasdivlf

	XREF	.GYasoplf

.GYasdivlf:

	move.l	(sp)+,d0				! pop current return address
	pea 	.Ylfdiv 				! operation wanted
	move.l	d0,-(sp)				! push back return address
	jmp 	.GYasoplf

#endif /* GCC_MATH */

#endif /* LONG_DOUBLE */

	END
