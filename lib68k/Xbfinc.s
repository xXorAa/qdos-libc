#
 ! C68 bit field auto increment/decrement routine
 !-----------------------------------------------------------------------------
 ! #1  First version.								   Dave Walker	 01/96
 ! #2  18 Sep 00 Converted directives to macrosized versions Dave Walker
 !-----------------------------------------------------------------------------

	SECTION TEXT

	XDEF	.Xbfinc
	XDEF	.Xbfdec


LHSPTR		equ 	4+0 			! pointer to LHS address
CODEWORD	equ 	4+4 			! coded size/offset/sign

!-------------------------------------------
!	   sp	   Return address
!	   sp+4    pointer to value to increment
!-------------------------------------------
.Xbfinc:
	moveq	#1,d0					! set for increment
	bra 	shared

.Xbfdec:
	moveq	#-1,d0					! set for decrement

shared:
	subq.l	#4,sp					! reserve space to save old value
	move.l	d0,-(sp)				! save value to add

	move.w	8+CODEWORD(sp),-(sp)
	move.l	10+LHSPTR(sp),-(sp)
	jsr 	.Xbfget 				! get bit field value
	move.l	d0,4(sp)				! save value for later
	add.l	d0,(sp) 				! add to inc/dec value
	move.w	8+CODEWORD(sp),-(sp)
	move.l	10+LHSPTR(sp),-(sp)
	jsr 	.Xbfput 				! store new bit field value

	move.l	(sp)+,d0				! pop saved value
	move.l	(sp)+,a1				! get return address
	addq.l	#6,sp					! tidy stack
	jmp 	(a1)					! return to caller

#ifdef GCC_MATH_FULL

	XDEF	_.GXbfinc
	XDEF	_.GXbfdec

!-------------------------------------------
!	   sp	   Return address
!	   sp+4    pointer to value to increment
!-------------------------------------------
_.GXbfinc:
	moveq	#1,d0					! set for increment
	bra 	Gshared

_.GXbfdec:
	moveq	#-1,d0					! set for decrement

Gshared:
	subq.l	#4,sp					! reserve space to save old value
	move.l	d0,-(sp)				! save value to add

	move.w	8+CODEWORD(sp),-(sp)
	move.l	10+LHSPTR(sp),-(sp)
	jsr 	.Xbfget 				! get bit field value
	move.l	d0,4(sp)				! save value for later
	add.l	d0,(sp) 				! add to inc/dec value
	move.w	8+CODEWORD(sp),-(sp)
	move.l	10+LHSPTR(sp),-(sp)
	jsr 	.Xbfput 				! store new bit field value
	rts

#endif

	END
