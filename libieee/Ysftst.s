#
* C68 4 byte floating point routine to test zero
*-----------------------------------------------------------------------------
*	#1	First version			Dave and Keith Walker		08/92
*	#2	Changed entry/exit code for C68 v4.3 compatibility	-djw-	09/93
*	#3	Changed for new parameter formats					-djw-	01/96
*  #4  Changed to allow directive types to be set				DJW    02/97
*-----------------------------------------------------------------------------

#include	"ieeeconf.h"

	SECTION text

	XDEF	.Ysftst

.Ysftst:

	move.l	(sp)+,a0		! get return address
	tst.l	(sp)+			! test it
	jmp	(a0)			! return

#ifdef GCC_MATH_FULL

	XDEF	.GYsftst

.GYsftst:

	tst.l	4(sp)			! test it
	rts

#endif /* GCC_MATH */

	END
