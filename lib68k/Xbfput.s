#
 ! C68 support routine to put a value into a bit field from a 32 bit value
 !-----------------------------------------------------------------------------
 ! #1  original version: David J. Walker							   10/95
 ! #2  18 Sep 00 Converted directives to macrosized versions Dave Walker
 !-----------------------------------------------------------------------------
 !
 !	Name:		.Xbfput
 !
 !	Parameters:
 !				LONG: Address of bit field
 !				WORD: value encoded with size/offset information as follows
 !
 !					Byte	Description
 !					~~~~	~~~~~~~~~~~
 !					 0		Offset of bit field in bits (0-31)
 !					 1		Size of bit field in bits (1-32)
 !							top bit set if value unsigned
 !
 !				LONG: value to be stored
 !
 !	The following assumptions are made:
 !	   1. The combination of offset and size cannot be larger than 32.
 !		  (i.e the value always fits into a long).
 !	   2. If the address passed is odd, the combination is limited to 24.
 !
 !---------------------------------------------------------------------------

#include "68kconf.h"

	SECTION TEXT

	XDEF	.Xbfput

BFPTR		EQU 	4+0
CODEWORD	EQU 	4+4
UNSIGNED	EQU 	4+4
SIZE		EQU 	4+4
OFFSET		EQU 	4+5
VALUE		EQU 	4+6

.Xbfput:

!	Load up registers as follows:
!		a0		Address of bit field
!		a1		Address of value
!		d1		Offset of bit field
!		d2		Size of bit field
!	If the bit field address is not even, then assume
!	that is less than 32 bits and make adjustments

		move.b	OFFSET(a7),d1		! get offset to start
		move.b	SIZE(a7),d2 		! get size
		move.l	BFPTR(a7),d0		! get bit field pointer value off stack
		bclr	#0,d0				! ensure even address ?
		beq 	waseven 			! ... it already was, so jump
		addq.b	#8,d1				! ... and adjust offset
waseven:
		move.l	d0,a0				! Move bit field address to a0
		lea 	VALUE(a7),a1		! get value address

!	Start by making certain that bits in memory
!	where bit field is to be stored are zero

		move.l	(a0),d0 			! get Long containing value
		rol.l	d1,d0				! left align field
		lsl.l	d2,d0				! clear bits that belong to value
		lsr.l	d2,d0				! ... and then back again
		ror.l	d1,d0				! back into position
		move.l	d0,(a0) 			! and store value with zero in bit field

!	Now get the bits that are to be stored in the
!	bit field into position ensuring all other
!	bits are set to zero

		move.l	(a1),d0 			! get value to be stored
		neg.b	d2					! - size
		add.b	#32,d2				! calculate 32 - size
		lsl.l	d2,d0				! move to top clearing other bits
		lsr.l	d1,d0				! move into position (offset)
		or.l	d0,(a0) 			! store result in space for it

!	We now need to get the value we stored back into
!	a long value to be returned as the result value

		lsl.l	d1,d0				! left align field
		btst	#7,d2				! was it unsigned?
		bne 	unsigned			! ... YES, jump
		asr.l	d2,d0				! ... NO, shift propogating sign
		bra 	finish
unsigned:
		lsr.l	d2,d0				! shift losing sign

!	Finished, so tidy up and exit

finish:
		move.l	(sp)+,a1			! get return address
		lea 	10(sp),sp			! tidy stack (pointer + short + long)
		jmp 	(a1)				! return to caller

#ifdef GCC_MATH_FULL

	XDEF	_.GXbfput

_.GXbfput:

!	Load up registers as follows:
!		a0		Address of bit field
!		a1		Address of value
!		d1		Offset of bit field
!		d2		Size of bit field
!	If the bit field address is not even, then assume
!	that is less than 32 bits and make adjustments

		move.b	OFFSET(a7),d1		! get offset to start
		move.b	SIZE(a7),d2 		! get size
		move.l	BFPTR(a7),d0		! get bit field pointer value off stack
		bclr	#0,d0				! ensure even address ?
		beq 	Gwaseven 			! ... it already was, so jump
		addq.b	#8,d1				! ... and adjust offset
Gwaseven:
		move.l	d0,a0				! Move bit field address to a0
		lea 	VALUE(a7),a1		! get value address

!	Start by making certain that bits in memory
!	where bit field is to be stored are zero

		move.l	(a0),d0 			! get Long containing value
		rol.l	d1,d0				! left align field
		lsl.l	d2,d0				! clear bits that belong to value
		lsr.l	d2,d0				! ... and then back again
		ror.l	d1,d0				! back into position
		move.l	d0,(a0) 			! and store value with zero in bit field

!	Now get the bits that are to be stored in the
!	bit field into position ensuring all other
!	bits are set to zero

		move.l	(a1),d0 			! get value to be stored
		neg.b	d2					! - size
		add.b	#32,d2				! calculate 32 - size
		lsl.l	d2,d0				! move to top clearing other bits
		lsr.l	d1,d0				! move into position (offset)
		or.l	d0,(a0) 			! store result in space for it

!	We now need to get the value we stored back into
!	a long value to be returned as the result value

		lsl.l	d1,d0				! left align field
		btst	#7,d2				! was it unsigned?
		bne 	Gunsigned			! ... YES, jump
		asr.l	d2,d0				! ... NO, shift propogating sign
		rts
Gunsigned:
		lsr.l	d2,d0				! shift losing sign
		rts

#endif /* GCC_MATH */

		END
