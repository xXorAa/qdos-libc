#
* C68 op= support where right hand side 'long double'
*				  and left hand side is integral type
*-----------------------------------------------------------------------------
*  #1  First version:	 David J. Walker							   01/96
*  #2  Changes to support macroized assembler directives	   -djw-   02/97
*-----------------------------------------------------------------------------
*
*  Name:	   .Xasoplf
*
*  Parameters:
*			   'long double' RHS value
*
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
*  In practise, most of the hard work is done in the 'Xasop' routine
*  that is shared by the 'Xasmul' and 'Xasdiv' routines
*
*---------------------------------------------------------------------------

#ifdef LONG_DOUBLE

#include "ieeeconf.h"

	SECTION text

	XDEF	.Yasoplf

	XREF	.Xbfget
	XREF	.Xbfput
	XREF	.Ylfltolf
	XREF	.Ylfutolf
	XREF	.Ylftol
	XREF	.Ylftoul

OPPTR		EQU   4+0
LHSPTR		EQU   4+4
CODEWORD	EQU   4+8
UNSIGNED	EQU   4+8
RHSVAL		EQU   4+10

.Yasoplf:
	movem.l RHSVAL(sp),d0/d1/d2 		! move across for later while registers free
	movem.l d0/d1/d2,-(sp)

	move.w	12+CODEWORD(sp),-(sp)		! coded word
	move.l	12+2+LHSPTR(sp),-(sp)		! bit field pointer
	jsr	.Xbfget 				! get it

	move.l	d0,-(sp)				! store for conversion routine
	btst	#7,12+4+UNSIGNED(sp)		! signed conversion?
	bne	2f
	jsr	.Ylfltolf			! YES
	bra	3f
2:	jsr	.Ylfutolf			! NO

3:	move.l	OPPTR(sp),a0			! get operation address
	movem.l d0/d1/d2,-(sp)			! store converted value as parameter
	jsr	(a0)				! do operation

	movem.l d0/d1/d2,-(sp)			! store result as parameter
	btst	#7,12+UNSIGNED(sp)		! signed conversion ?
	bne	5f
	jsr	.Ylftol 			! YES
	bra	6f
5:	jsr	.Ylftoul			! NO

6:	move.l	d0,-(sp)			! value to store as parameter
	move.w	4+CODEWORD(sp),-(sp)		! coded word
	move.l	6+LHSPTR(sp),-(sp)		! ...and target location
	jsr	.Xbfput 			! store result

	move.l	(sp)+,a1			! get return address
	lea	22(sp),sp			! tidy stack (2xpointer + short + long double)
	jmp	(a1)				! return to caller

#ifdef GCC_MATH_FULL

	XDEF	.GYasoplf

.GYasoplf:
	movem.l RHSVAL(sp),d0/d1/d2 		! move across for later while registers free
	movem.l d0/d1/d2,-(sp)

	move.w	12+CODEWORD(sp),-(sp)		! coded word
	move.l	12+2+LHSPTR(sp),-(sp)		! bit field pointer
	jsr	.Xbfget 			! get it

	move.l	d0,-(sp)			! store for conversion routine
	btst	#7,12+4+UNSIGNED(sp)		! signed conversion?
	bne	G2
	jsr	.Ylfltolf			! YES
	bra	G3
G2:	jsr	.Ylfutolf			! NO

G3:	move.l	OPPTR(sp),a0			! get operation address
	movem.l d0/d1/d2,-(sp)			! store converted value as parameter
	jsr	(a0)				! do operation

	movem.l d0/d1/d2,-(sp)			! store result as parameter
	btst	#7,12+UNSIGNED(sp)		! signed conversion ?
	bne	G5
	jsr	.Ylftol 			! YES
	bra	G6
G5:	jsr	.Ylftoul			! NO

G6:	move.l	d0,-(sp)			! value to store as parameter
	move.w	4+CODEWORD(sp),-(sp)		! coded word
	move.l	6+LHSPTR(sp),-(sp)		! ...and target location
	jsr	.Xbfput 			! store result

	move.l	(sp)+,a1			! get return address.
	move.l	a1,(sp)				! overwrite opcode address with it
	rts

#endif /* GCC_MATH */

#endif /* LONG_DOUBLE */

	END
