#
* C68 op= support where right hand side 'float' type
*				  and left hand side is integral type
*-----------------------------------------------------------------------------
*  #1  First version:	 David J. Walker							   01/96
*  #2  Changes to support macroized assembler directives	   -djw-   02/97
*-----------------------------------------------------------------------------
*
*  Name:	   .Yasopsf
*
*  Parameters:
*			   Pointer to operation routine
*			   Pointer to LHS value
*			   Short value encoded with size/type information as follows
*
*				   Byte    Description
*				   ~~~	   ~~~~~~~~~~~
*				   0	Offset of LHS in bits (0 if not bitfield)
*						Top bit set if unsigned
*				   1	Size of LHS in bits
*
*			   'Float' RHS value
*
*  In practise, most of the hard work is done in the 'Xasop' routine
*  that is shared by the 'Xasmul' and 'Xasdiv' routines
*
*---------------------------------------------------------------------------

#include "ieeeconf.h"

	SECTION text

	XDEF	.Yasopsf

	XREF	.Xbfget
	XREF	.Xbfput
	XREF	.Xsfltosf
	XREF	.Xsfutosf
	XREF	.Xsftol
	XREF	.Xsftoul

OPPTR		EQU  4+0
LHSPTR		EQU  4+4
CODEWORD	EQU  4+8
UNSIGNED	EQU  4+8
RHSVAL		EQU  4+10

.Yasopsf:

	move.w	CODEWORD(sp),-(sp)
	move.l	2+LHSPTR(sp),-(sp)
	jsr	.Xbfget

	move.l	d0,-(sp)
	btst	#7,4+UNSIGNED(sp)		! check if unsigned
	bne	2f
	jsr	.Ysfltosf
	bra	3f
2:	jsr	.Ysfutosf

3:	move.l	OPPTR(sp),a0			! get operation address
	move.l	RHSVAL(sp),-(sp)
	move.l	d0,-(sp)
	jsr	(a0)				! do operation

	move.l	d0,-(sp)
	btst	#7,4+UNSIGNED(sp)		! check if unsigned
	bne	5f
	jsr	.Ysftol
	bra	6f
5:	jsr	.Ysftoul

6:	move.l	d0,-(sp)			! value to store as parameter
	move.w	4+CODEWORD(sp),-(sp)		! coded word
	move.l	6+LHSPTR(sp),-(sp)		! ...and target location
	jsr	.Xbfput 			! store result

	move.l	(sp)+,a1			! get return address
	lea	14(sp),sp			! tidy stack (2xpointer + short + float)
	jmp	(a1)				! return to caller

#ifdef GCC_MATH_FULL

	XDEF	.GYasopsf

.GYasopsf:

	move.w	CODEWORD(sp),-(sp)
	move.l	2+LHSPTR(sp),-(sp)
	jsr	.Xbfget

	move.l	d0,-(sp)
	btst	#7,4+UNSIGNED(sp)		! check if unsigned
	bne	G2
	jsr	.Ysfltosf
	bra	G3
G2:	jsr	.Ysfutosf

G3:	move.l	OPPTR(sp),a0			! get operation address
	move.l	RHSVAL(sp),-(sp)
	move.l	d0,-(sp)
	jsr	(a0)				! do operation

	move.l	d0,-(sp)
	btst	#7,4+UNSIGNED(sp)		! check if unsigned
	bne	G5
	jsr	.Ysftol
	bra 	G6
G5:	jsr	.Ysftoul

G6:	move.l	d0,-(sp)			! value to store as parameter
	move.w	4+CODEWORD(sp),-(sp)		! coded word
	move.l	6+LHSPTR(sp),-(sp)		! ...and target location
	jsr	.Xbfput 			! store result
	move.l	(sp)+,a1			! get return address.
	move.l	a1,(sp)				! overwrite opcode address with it
	rts

#endif /* GCC_MATH */

	END
