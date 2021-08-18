#
! c68 support routines
! ~~~~~~~~~~~~~~~~~~~~
!
! Shifting of long long quantities
! (these may be later made inline if short enough
!  generic code sequences are identified)
!
! Prototypes:
!	long long			.Xllshr  (long long a, int n);
!	unsigned long long	.Xullshr  (unsigned long long a, int n);
!	void				.Xasllshr (long long *a, int n);
!	void				.Xasullshr (unsigned long long *a, int n);
!	long long			.Xllshl  (long long a, int n);
!	unsigned long long	.Xullshl  (unsigned long long a, int n);
!	void				.Xasllshl (long long *a, int n);
!	void				.Xasullshl (unsigned long long *a, int n);

! Amendment History
! ~~~~~~~~~~~~~~~~~~
! #1  09 Aug 00 First version							Dave Walker
! #2  18 Sep 00 Converted directives to macrosized versions Dave Walker
!
#include "68kconf.h"

	SECTION TEXT
	SECTION ROM
	SECTION DATA
	SECTION BSS


!	Left shifts - these are always the same if signed or unsigned

	SECTION TEXT

	XDEF	.Xllshl
	XDEF	.Xullshl

.Xllshl:
.Xullshl:
	move.l	4+0(a7),d0			! get value
	move.l	4+4(a7),d1
	move.l	4+8(a7),d2			! get count
	cmp.l	#64,d2				! see if valid range
	bmi 	valid_shl

!	If shift value is 64 bits or more then all bits shifted away!

toolarge:
	moveq	#0,d0				! force result to be all bits clear
	moveq	#0,d1
	bra 	tidyup				! ... and exit

valid_shl:
	cmp.l	#32,d2				! see if larger than 32
	bmi 	small_shl

!	Easy case - least significant par will always be zero
!				most significant part is least significant part
!				shifted be remaining count
large_shl:
	sub.b	#32,d2				! reduce count
	lsl.l	d2,d1				! move left least significant part
	move.l	d1,d0				! move to most significant part
	moveq	#0,d1				! clear least significant part
	bra 	tidyup				! go to exit

small_shl:
	lsl.l	d2,d0				! move most significant part left
	move.l	d0,-(a7)			! and save result to free register
	move.l	d1,d0				! copy least significant part
	lsl.l	d2,d1				! and fix least significant
	sub.l	#32,d2				! convert count to right shift value
	neg.l	d2
	lsr.l	d2,d0				! move by remnant count
	or.l	(a7)+,d0			! add in original value
tidyup:
	move.l	(a7)+,a0			! get return value
	lea 	8+4(a7),a7			! remove parameters
	jmp 	(a0)				! return to caller

!	shift assign variants all use normal variant internally

	XDEF	.Xasllshl
.Xasllshl:
	lea 	.Xllshl(pc),a0
	bra 	do_asl
!
	XDEF	.Xasullshl
.Xasullshl:
	lea 	.Xullshl(pc),a0
	bra 	do_asl
!
	XDEF	.Xasllshr
.Xasllshr:
	lea 	.Xllshr(pc),a0
	bra 	do_asl
!
	XDEF	.Xasullshr
.Xasullshr:
	lea 	.Xullshr(pc),a0

do_asl:
	move.l	4+4(a7),a1			! second operand (count)
	move.l	a1,-(a7)			! store copy of second operand
	move.l	4+4+0(a7),a1		! pointer to first operand (results area)
	move.l	0(a1),-(a7) 		! store value for first operand
	move.l	4(a1),-(a7)
	jsr 	(a0)				! Call required routine
!				  a1 not destroyed (but stack tidied)
	move.l	d0,(a1) 			! assign result
	move.l	d1,4(a1)
tidyup_as:
	move.l	(a7)+,a0			! get return address
	lea 	4+4(a7),a7			! remove parameters from stack
	jmp 	(a0)				! return to calling point


!	Signed - the standard allows us to use unsigned shifts as the results
!	of shifts that would be different if signed shifts were used is undefined.
!	However quite a bit of code is believed to need sign extension

	XDEF	.Xllshr

.Xllshr:

!	Code that supports propgating of signed bit

	move.l	4+0(a7),d0			! get value
	move.l	4+4(a7),d1
	move.l	4+8(a7),d2			! get count
	cmp.l	#64,d2				! see if valid range
	bpl 	toolarge
	cmp.l	#32,d2				! see if larger than 32
	bmi 	small_shr

!	Easy case - most significant part will always be same as sign bit
!				most significant part is least significant part
!				shifted be remaining count
large_shr:
	sub.b	#32,d2
	asr.l	d2,d0				! move right most significant part
	move.l	d0,d1				! move to least significant part
	moveq	#0,d0
	tst.l	d1					! is result negative?
	bpl 	tidyup				! ... yes exit immediately
	moveq	#-1,d0				! ... no, set bits in most significant part
	bra 	tidyup				! go to exit

small_shr:
	lsr.l	d2,d1				! move least significant part right
	move.l	d1,-(a7)			! and save result to free register
	move.l	d0,d1				! copy most significant part
	asr.l	d2,d0				! and fix most significant
	bra 	shared_shr

!	Unsigned - use logical shifts

	XDEF	.Xullshr
.Xullshr:
	move.l	4+0(a7),d0			! get value
	move.l	4+4(a7),d1
	move.l	4+8(a7),d2			! get count
	cmp.l	#64,d2				! see if valid range
	bpl 	toolarge
	cmp.l	#32,d2				! see if larger than 32
	bmi 	small_ushr

!	Easy case - most significant part will always be zero
!				least significant part is least significant part
!				shifted by remaining count
large_ushr:
	sub.b	#32,d2
	lsr.l	d2,d0				! move right most significant part
	move.l	d0,d1				! move to most significant part
	moveq	#0,d0				! clear most significant part
	bra 	tidyup				! go to exit

small_ushr:
	lsr.l	d2,d1				! move least significant part right
	move.l	d1,-(a7)			! and save result to free register
	move.l	d0,d1				! copy most significant part
	lsr.l	d2,d0				! and fix most significant

shared_shr:
	sub.b	#32,d2				! convert count to left shift value
	neg.l	d2
	lsl.l	d2,d1				! move by remnant count
	or.l	(a7)+,d1			! add in original value
	bra 	tidyup

	END
