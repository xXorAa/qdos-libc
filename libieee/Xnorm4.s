#
* C68 4-byte-floating point normalization routine
*-----------------------------------------------------------------------------
* ported to 68000 by Kai-Uwe Bloem, 12/89
*  #1  original author: Peter S. Housel
*  #2  added support for denormalized numbers					-kub-, 01/90
*  #3  Changed entry point name for C68 comaptibility, and
*	   changed error handling code. 							-djw-	09/93
*  #4  Changes to support macroized assembler directives		-djw-	02/97
*-----------------------------------------------------------------------------

#include	"ieeeconf.h"

	SECTION text

	XDEF	.Xnorm4

*-----------------------------------------------
* on entry to .Xnorm4:
*	D0.w	exponent of result
*	D2.w	sign byte in left most bit position
*		sticky bit in least significant byte
*	D1.b	rounding bits
*	A1	mantissa pointer
*-----------------------------------------------

.Xnorm4:
	movem.l	d3-d5,-(sp) 			! save some registers

	move.l	(a1),d4 			! rounding and u.mant == 0 ?
	bne 	0f
	tst.b	d1
	beq	retz
0:
	clr.b	d2				! "sticky byte"
	move.l	#0xff000000,d5
1:	tst.w	d0				! divide (shift)
	ble 	0f				! denormalized number
9:	move.l	d4,d3
	and.l	d5,d3				!  or until no bits above 23
	beq 	2f
0:	add.w	#1,d0				! increment exponent
	lsr.l	#1,d4
	or.b	d1,d2				! set "sticky"
	bra 	9b
2:
	and.b	#1,d2
	or.b	d2,d1				! make least sig bit "sticky"
	move.l	#0xff800000,d5
3:	move.l	d4,d3				! multiply (shift) until
	and.l	d5,d3				! one in "implied" position
	bne 	4f
	sub.w	#1,d0				! decrement exponent
	beq 	4f					!  too small. store as denormalized number
	add.b	d1,d1				! some doubt about this one *
	addx.l	d4,d4
	bra 	3b
4:
	tst.b	d1				! check rounding bits
	bge 	6f				! round down - no action neccessary
	neg.b	d1
	bvc 	5f				! round up
	btst	#0,d4				! tie case - use state of last bit
	beq 	0f				! .. no rounding needed
5:
	clr.w	d1				! zero rounding bits
	add.l	#1,d4
	tst.w	d0
	bne 	0f				! renormalize if number was denormalized
	add.w	#1,d0				! correct exponent for denormalized numbers
	bra 	1b
0:	move.l	d4,d3				! check for rounding overflow
	and.l	#0xff000000,d3
	bne 	1b				! go back and renormalize
6:
	tst.l	d4				! check if normalization caused an underflow
	beq 	retz
	tst.w	d0				! check for exponent overflow or underflow
	blt 	retz
	cmp.w	#255,d0
	bge 	oflow

	lsl.w	#7,d0				! re-position exponent
	and.w	#0x8000,d2			! sign bit
	or.w	d2,d0
	swap	d0				! map to upper word
	clr.w	d0
	and.l	#0x7fffff,d4			! top mantissa bits
	or.l	d0,d4				! insert exponent and sign
	move.l	d4,(a1)
finish:
	movem.l (sp)+,d3-d5
	move.l	(a1),d0
	rts

retz:
	clr.l	(a1)
	bra 	finish

oflow:
	jsr 	.overflow			! call routine to raise FP exception
	move.l	d0,(a1) 			! return made - set return value
	bra 	finish

	END
