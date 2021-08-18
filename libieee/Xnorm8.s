#
* C68 8-byte-floating point normalization routine
*-----------------------------------------------------------------------------
* ported to 68000 by Kai-Uwe Bloem, 12/89
*	#1	original author: Peter S. Housel
*	#2	replaced shifts by swap if possible for speed increase	-kub-, 01/90
*	#3	add handling for denormalized numbers					-kub-, 01/90
*	#4	Changed entry point name for C68 v4.3 compatibility
*		Changed handling of overflow error						-djw-  09/93
*	#8	Changes to support macroized assembler directives		-djw-	02/97
*-----------------------------------------------------------------------------

#include "ieeeconf.h"

	SECTION text

	XDEF	.Xnorm8

*-----------------------------------------------
* on entry to norm8:
*	D0.w	exponent value of result
*	D2.w	sign byte in left most bit position
*		sticky bit in least significant byte
*	D1	rounding bits
*	A1	mantissa pointer
*-----------------------------------------------

.Xnorm8:
	moveq	#0,d1
	movem.l	d3-d6,-(sp)		! save some registers

	movem.l	(a1),d4-d5
	move.l	d4,d3			! rounding and u.mant == 0 ?
	or.l	d5,d3
	bne	1f
	tst.b	d1
	beq	retz
1:
	move.l	d4,d3
	and.l	#0xfffff000,d3		! fast shift, 16 bits ? <-- NO !!! (TG)
	bne	2f
	cmp.w	#9,d0			! shift is going to far; do normal shift
	ble	2f			!  (minimize shifts here : 10l = 16l + 6r)
	swap	d4			! yes, swap register halfs
	swap	d5
	move.w	d5,d4
	move.b	d1,d5			! some doubt about this one !
	lsl.w	#8,d5
	clr.w	d1
	sub.w	#16,d0			! account for swap
	bra	1b
2:
	clr.b	d2			! "sticky byte"
	move.l	#0xffe00000,d6
3:	tst.w	d0			! divide (shift)
	ble	0f			!  denormalized number
4:	move.l	d4,d3
	and.l	d6,d3			!  or until no bits above 53
	beq	4f
0:	addq.w	#1,d0			! increment exponent
	lsr.l	#1,d4
	roxr.l	#1,d5
	or.b	d1,d2			! set "sticky"
	roxr.b	#1,d1			! shift into rounding bits
	bra	4b
4:
	and.b	#1,d2
	or.b	d2,d1			! make least sig bit "sticky"
	move.l	#0xfff00000,d6
5:	move.l	d4,d3			! multiply (shift) until
	and.l	d6,d3			! one in "implied" position
	bne 6f
	subq.w	#1,d0			! decrement exponent
	beq 6f				!  too small. store as denormalized number
	add.b	d1,d1			! some doubt about this one *
	addx.l	d5,d5
	addx.l	d4,d4
	bra	5b
6:
	tst.b	d1			! check rounding bits
	bge	8f			! round down - no action neccessary
	neg.b	d1
	bvc	7f			! round up
	btst	#0,d5			! tie case - use state of last bit
	beq	8f			! .. no rounding needed
7:
	moveq	#0,d1			! zero rounding bits
	add.l	#1,d5
	addx.l	d1,d4
	tst.w	d0
	bne	0f			! renormalize if number was denormalized
	addq.w	#1,d0			! correct exponent for denormalized numbers
	bra	2b
0:	move.l	d4,d3			! check for rounding overflow
	and.l	#0xffe00000,d3
	bne	2b			! go back and renormalize
8:
	move.l	d4,d3			! check if normalization caused an underflow
	or.l	d5,d3
	beq	retz
	tst.w	d0			! check for exponent overflow or underflow
	blt	retz
	cmp.w	#2047,d0
	bge	oflow

	lsl.w	#4,d0			! re-position exponent
	and.w	#0x8000,d2		! sign bit
	or.w	d2,d0
	swap	d0			! map to upper word
	clr.w	d0
	and.l	#0x0fffff,d4		! top mantissa bits
	or.l	d0,d4			! insert exponent and sign
	movem.l	d4-d5,(a1)
finish: movem.l	(sp)+,d3-d6
	movem.l	(a1),d0/d1
	rts

retz:
	clr.l	0(a1)
	clr.l	4(a1)
	bra	finish

oflow:	jsr	.overflow		! call overflow exception routine
	movem.l	d0-d1,(a1)		! set reurn value
	bra	finish			! ... and exit

	END
