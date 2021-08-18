#
* C68 /= support where right hand side floating point
*				  and left hand side is integral type
*-----------------------------------------------------------------------------
*  #1  First version:	 David J. Walker							   01/96
*  #2  Changes to support macroized assembler directives	   -djw-   02/97
*-----------------------------------------------------------------------------
*
*  Name:	   .Yasdivsf
*
*  This is just a wrapper around the shared '.Yasopsf' routine
*---------------------------------------------------------------------------

#include "ieeeconf.h"

	SECTION text

	XDEF	.Yasdivsf

	XREF	.Ysfdiv
	XREF	.Yasopsf

.Yasdivsf:

	move.l	(sp)+,d0				! pop current return address
	pea 	.Ysfdiv 				! operation wanted
	move.l	d0,-(sp)				! push back return address
	jmp 	.Yasopsf

#ifdef GCC_MATH_FULL

	XDEF	.GYasdivsf

	XREF	.GYasopsf

.GYasdivsf:

	move.l	(sp)+,d0				! pop current return address
	pea 	.Ysfdiv 				! operation wanted
	move.l	d0,-(sp)				! push back return address
	jmp 	.GYasopsf

#endif /* GCC_MATH */

	END
