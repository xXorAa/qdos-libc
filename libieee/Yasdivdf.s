#
* C68 /= support where right hand side 'double' type
*				  and left hand side is integral type
*-----------------------------------------------------------------------------
*  #1  First version:	 David J. Walker							   01/96
*  #2  Changes to support macroized assembler directives	   -djw-   02/97
*-----------------------------------------------------------------------------
*
*  Name:	   .Yasdivdf
*
*  This is just a wrapper around the shared '.Yasopdf' routine
*---------------------------------------------------------------------------

#include "ieeeconf.h"

	SECTION text

	XDEF	.Yasdivdf

	XREF	.Ydfdiv
	XREF	.Yasopdf

.Yasdivdf:

	move.l	(sp)+,d0				! pop current return address
	pea 	.Ydfdiv 				! operation wanted
	move.l	d0,-(sp)				! push back return address
	jmp 	.Yasopdf

#ifdef GCC_MATH_FULL

	XDEF	.GYasdivdf

	XREF	.GYasopdf

.GYasdivdf:

	move.l	(sp)+,d0				! pop current return address
	pea 	.Ydfdiv 				! operation wanted
	move.l	d0,-(sp)				! push back return address
	jmp 	.GYasopdf

#endif /* GCC_MATH */

	END
