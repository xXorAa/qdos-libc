#
* C68 *= support where right hand side 'float'
*				  and left hand side is integral type
*-----------------------------------------------------------------------------
*  #1  First version:	 David J. Walker							   01/96
*  #2  Changes to support macroized assembler directives	   -djw-   02/97
*-----------------------------------------------------------------------------
*
*  Name:	   .Xasdivsf
*
*  This is just a wrapper around the shared '.Yasopsf' routine
*---------------------------------------------------------------------------

#include "ieeeconf.h"

	SECTION .text

	XDEF	.Yasmulsf

	XREF	.Ysfmul
	XREF	.Yasopsf

.Yasmulsf:

	move.l	(sp)+,d0				! pop current return address
	pea 	.Ysfmul 				! operation wanted
	move.l	d0,-(sp)				! push back return address
	jmp 	.Yasopsf

#ifdef GCC_MATH_FULL

	XDEF	.GYasmulsf

	XREF	.GYasopsf

.GYasmulsf:

	move.l	(sp)+,d0				! pop current return address
	pea 	.Ysfmul 				! operation wanted
	move.l	d0,-(sp)				! push back return address
	jmp	.GYasopsf				!

#endif /* GCC_MATH */

	END
