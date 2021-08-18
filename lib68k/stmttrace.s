#
! Statement Trace Routine
!
! Called from C68 if the -tracek runtime option is selected.
!
! The -trace option in C68/c386 is intended as a way of allowing a
! source level debugger, or a profiller to be implemented.
!
! The code supplied here is merely a dummy that causes any calls to the
! statement trace code to return without doing anything.  It would need
! to be extended as appropriate to suite the function that was required
! of it.
! 
! Amendement History
! ~~~~~~~~~~~~~~~~~~
! #1  22 Jan 93 First Version							Dave Walker
! #2  18 Sep 00 Converted directives to macrosized versions Dave Walker


#include "68kconf.h"
!
!
! Export: .stmttrace
!
	SECTION TEXT

	XDEF	.stmttrace

.stmttrace:

!
!	The exit code.	In the case of a dummy version of this
!	routine, this is all that is needed.
!
	move.l	(a7)+,a0			! get return address
	addq.l	#8,a7				! tidy stack by removing parameters
	jmp 	(a0)				! return to calling point

	END
