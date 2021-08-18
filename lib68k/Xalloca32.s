#
! Copyright 1991, Christoph van Wuellen
! alloca function for c68
! can handle also __builtin_alloca()
!
! #4  18 Sep 00 Converted directives to macrosized versions Dave Walker

#include "68kconf.h"

!
	SECTION TEXT
	SECTION ROM
	SECTION DATA
	SECTION BSS
	SECTION TEXT

	.globl _alloca
	.globl ___builtin_alloca

_alloca:
___builtin_alloca:
	move.l	(a7)+,a0		! return address
	move.l	(a7),d0 		! argument (32 bit!)
	add.l	#1,d0
	and.l	#-2,d0			! align request
	sub.l	d0,a7			! adjust stack pointer
	move.l	a7,d0			! return value
	add.l	#4,d0			! adjust for pop-off (32 bit)
	jmp 	(a0)

	END
