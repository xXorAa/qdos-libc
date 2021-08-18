#
* C68 /= support where right hand side 'double'
*				  and left hand side is integral type
*-----------------------------------------------------------------------------
*  #1  First version:	 David J. Walker							   01/96
*  #2  Changes to support macroized assembler directives	   -djw-   02/97
*-----------------------------------------------------------------------------
*
*  Name:	   .Xasopdf
*
*  Parameters:
*			   Pointer to operation routine
*			   Pointer to LHS value
*			   Short value encoded with size/type information as follows
*
*				   Byte    Description
*				   ~~~	   ~~~~~~~~~~~
*				   0	Offset of LHS in bits (0 if not bitfield)
*						Top bit set if unsigned type
*				   1	Size of LHS in bits
*
*			   'double' RHS value
*
*  In practise, most of the hard work is done in the 'Xasop' routine
*  that is shared by the 'Xasmul' and 'Xasdiv' routines
*
*---------------------------------------------------------------------------

#include "ieeeconf.h"

	SECTION text

	XDEF	.Yasopdf

	XREF	.bfget
	XREF	.bfput
	XREF	.Ydfltodf
	XREF	.Ydfutodf
	XREF	.Ydftol
	XREF	.Ydftoul

OPPTR		EQU  4+0
LHSPTR		EQU  4+4
CODEWORD	EQU  4+8
UNSIGNED	EQU  4+8
RHSVAL		EQU  4+10

.Yasopdf:

	movem.l	RHSVAL(sp),d0/d1		! get value while registers free
	movem.l	d0/d1,-(sp) 			! store on stack for later

	move.w	8+CODEWORD(sp),-(sp)
	move.l	8+2+LHSPTR(sp),-(sp)
	jsr	.Xbfget

	move.l	d0,-(sp)
	btst	#7,8+4+UNSIGNED(sp) 		! signed conversion ?
	bne	2f
	jsr	.Ydfltodf			! Yes
	bra	3f
2:	jsr	.Ydfutodf			! No

3:	move.l	8+OPPTR(sp),a0			! get operation address
	movem.l	d0/d1,-(sp) 			! store converted value as parameter
	jsr	(a0)				! do operation

	movem.l	d0/d1,-(sp) 			! store result as parameter for conversion
	btst	#7,8+UNSIGNED(sp)		! signed conversion ?
	bne	5f
	jsr	.Ydftol 			! Yes
	bra	6f
5:	jsr	.Ydftoul			! No

!	N.B.  the 8 bytes stored for the 'op' routine have now gone

6:	move.l	d0,-(sp)			! value to store as parameter
	move.w	4+CODEWORD(sp),-(sp)		! coded word
	move.l	6+LHSPTR(sp),-(sp)		! ...and target location
	jsr	.Xbfput 			! store result

	move.l	(sp)+,a1			! get return address
	lea	18(sp),sp			! tidy stack (2xpointer + short + double)
	jmp	(a1)				! return to caller

#ifdef GCC_MATH_FULL

	XDEF	.GYasopdf

.GYasopdf:

	movem.l RHSVAL(sp),d0/d1		! get value while registers free
	movem.l d0/d1,-(sp) 			! store on stack for later

	move.w	8+CODEWORD(sp),-(sp)
	move.l	8+2+LHSPTR(sp),-(sp)
	jsr	.Xbfget

	move.l	d0,-(sp)
	btst	#7,8+4+UNSIGNED(sp) 		! signed conversion ?
	bne	G2
	jsr	.Ydfltodf			! Yes
	bra	G3
G2:	jsr	.Ydfutodf			! No

G3:	move.l	8+OPPTR(sp),a0			! get operation address
	movem.l d0/d1,-(sp) 			! store converted value as parameter
	jsr	(a0)				! do operation

	movem.l	d0/d1,-(sp) 			! store result as parameter for conversion
	btst	#7,8+UNSIGNED(sp)		! signed conversion ?
	bne	G5
	jsr	.Ydftol 			! Yes
	bra	G6
G5:	jsr	.Ydftoul			! No

!	N.B.  the 8 bytes stored for the 'op' routine have now gone

G6:	move.l	d0,-(sp)			! value to store as parameter
	move.w	4+CODEWORD(sp),-(sp)		! coded word
	move.l	6+LHSPTR(sp),-(sp)		! ...and target location
	jsr	.Xbfput 			! store result

	move.l	(sp)+,a1			! get return address.
	move.l	a1,(sp)				! overwrite opcode address with it
	rts

#endif /* GCC_MATH */

	END
