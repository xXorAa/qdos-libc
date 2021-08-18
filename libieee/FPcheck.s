#
*		F P c h e c k . x
*
*	Routines that check for availability of FPU,
*	reserve it for use, and release it after use.
*
*	Note that these routines will be VERY machine and
*	operating system specific.
*
*	AMENDMENT HISTORY
*	~~~~~~~~~~~~~~~~~
*	23 Feb 97	DJW   - Changed to work with George Gwilts FPSAVE
*						floating point support for QDOS and SMS.
*						This simplifies the code significantly and
*						should lead to performance boosts as a result.
*	28 Feb 97	DJW   - Changes to support macroized assembler directives		-djw-	02/97
*						Changes to supported macroized	HW_FPU interface
*	10 May 98	DJW   - Added flushing of caches as otherwise there can
*						be problems with self-modifying code on processors
*						that have caches!
*	31 Oct 98	DJW   - Removed extra CacheFlush that is not needed.
*					  - Reordered tests on __FpuFlag to get a slightly
*						more effecient path when already set negative.
*					  - Made __FpuFlag variable no longer globally visible.
*--------------------------------------------------------------------

#include "ieeeconf.h"

	SECTION text

	XDEF	__FPcheck
	XDEF	__FPrelease

#ifdef QDOS
SYS_PTYP  EQU 0xa1

SYS_FPHW  EQU 0xd0
SYS_FPSZ  EQU 0xd2

*---------------------------------------------------------------------
*	_ F P c h e c k
*
*	This routine is used to check for availability of
*	the hardware FPU, and if present reserve it for use.
*
*				Input		Output
*				~~~~~		~~~~~~
*		D0		?			Smashed
*		A0		?			Smashed
*		A1		?			Smashed
*
*	All other registers preserved
*
*	This code modifies the calling point to avoid the need to
*	repeatedly call this routine.  This is a little 'dirty' in
*	programming terms, but it does speed things up!
*
*	On exit condition codes (and D0) set to minus if there
*	is no hardware FPU present (or it cannot be reserved).
*---------------------------------------------------------------------
	SECTION 	data

*	.globl	__FpuFlag
__FpuFlag:
		dc.l	1					! This is set to indicate state of FPU
									! 0 = Yes, -ve = NO, +ve = check not done

	SECTION 	text

__FPcheck:
		move.l	__sys_var,a0		! get address of system variables
		move.b	SYS_FPHW(a0),d0 	! get flag
		beq 	nofpu				! ... clear - set to not use FPU
		bmi 	patch				! ... negative, skip straight to patch out use of FPU

		move.w	SYS_FPSZ(a0),d0 	! check that FP_SAVE loaded
		beq 	nofpu				! ... NO, so also do not use FPU
		clr.l	__FpuFlag			! set to say we have FPU and FP_SAVE

*	This is the 'untidy' bit of code that patches
*	the code that called this routine to in future
*	read the variable directly without a branch.

patch:
		move.l	(sp),a0 			! get return address
		move.w	finish,-6(a0)		! move over op code
		move.l	finish+2,-4(a0) 	! move over address (long)
		jsr 	__CacheFlush		! flush the caches (if any)
finish:
		move.l	__FpuFlag,d0			! set result code
		rts

nofpu:
		move.l	#-1,__FpuFlag		! set to not use FPU
		bra 	patch

__FPrelease:
		rts

#endif /* QDOS */

		END
