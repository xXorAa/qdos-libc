#
* C68 *= support where right hand side 'double' type
*				  and left hand side is integral type
*-----------------------------------------------------------------------------
*  #1  First version:	 David J. Walker							   01/96
*  #2  Changes to support macroized assembler directives	   -djw-   02/97
*-----------------------------------------------------------------------------
*
*  Name:	   .Yasmuldf
*
*  This is just a wrapper around the shared '.Yasopsf' routine
*---------------------------------------------------------------------------

#include "ieeeconf.h"

	SECTION text

	XDEF	.Yasmuldf

	XREF	.Ydfmul
	XREF	.Yasopdf

.Yasmuldf:

	move.l	(sp)+,d0				! pop current return address
	pea 	.Ydfmul 				! operation wanted
	move.l	d0,-(sp)				! push back return address
	jmp 	.Yasopdf

#ifdef GCC_MATH_FULL

	XDEF	.GYasmuldf

	XREF	.GYasopdf

.GYasmuldf:

	move.l	(sp)+,d0				! pop current return address
	pea 	.Ydfmul 				! operation wanted
	move.l	d0,-(sp)				! push back return address
	jmp 	.GYasopdf

#endif /* GCC_MATH */

	END
