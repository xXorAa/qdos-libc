#
! Stack check routine.
!
! Called from C68 if the -stackcheck runtime option is selected.
!
! The details of how this routine should be implemented will be
! different for each combination of processor and operating system.
! This file contains examples of how this has been used in a couple
! of specific cases, plus the minimum code needed for this routine
! to act as a dummy.
! 
! Amendement History
! ~~~~~~~~~~~~~~~~~~
! #1  19 Jan 93 First Version							Dave Walker
! #2  18 Sep 00 Converted directives to macrosized versions Dave Walker
!
#include "68kconf.h"
!
! Export: .stackcheck
!
	SECTION TEXT

	XDEF	.stackcheck

	XREF	__SPbase
	XREF	__stackmargin
	XREF	__stack
	XREF	__stackmax
	XREF	__stack_newmax
	XREF	__stack_error
	XREF	__exit

.stackcheck:

#ifdef QDOS
!	The implementation for C68 on the QDOS operating system
!
	move.l	a7,d0				; get stack pointer value
	sub.l	__SPbase,d0 		; ... less base to get current margin
	sub.l	4(a7),d0			; ... less new amount wanted
	cmp.l	__stackmargin,d0	; less than margin we must allow ?
	bmi 	err 				; ... YES, go to report error 
	move.l	__stack,d1			; get original stack size
	sub.l	d0,d1				; ... less amount left
	cmp.l	__stackmax,d1		; is this a new max
	bpl 	max 				; ... YES, go to set new max
#endif /* QDOS */
!
!	The exit code.	In the case of a dummy version of this
!	routine, this is all that is needed.
!
fin:
	move.l	(a7)+,a0			! get return address
	addq.l	#4,a7				! tidy stack by removing parameters
	jmp 	(a0)				! return to calling point

#ifdef QDOS
!	We expect that routine we call here to abort the program !
err:
	move.l	__exit,(a7) 		; set abort routine as return address
	jmp 	__stack_error		; call error reporting routine
!
!	This routine can do whatever it likes.	Typically this 
!	would be to update statistics on stack useage.
max:
	move.l	d1,__stackmax		; store new maximum
	jsr 	__stack_newmax		; call routine when new max reached
	bra 	fin
#endif	/* QDOS */

	END
