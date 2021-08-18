/*
*		i e e e c o n f . h
*
*	Header file that sets up definitions used within the 
*	IEEE support routines for the C68 compiler.
*
*	AMENDMENT HISTORY
*	~~~~~~~~~~~~~~~~~
*	21 Feb 97	DJW   - First version.
*						Allows Motorola format assembler directives to
*						be used in source files, but if necessary will
*						redefine them to the syntax used by the Minix ACK
*						assembler (and thus AS68 under QDOS).
*------------------------------------------------------------------------*/

/*	 Check that the syntax is defined	*/

#ifdef AS68
#define ACK
#endif

#ifndef ACK
#ifndef MOTOROLA
#define MOTOROLA
#endif /* MOTOROLA */
#endif /* ACK */

/*	 Check that we do not generate HW FPU support	*/
/*	 if we are not generating QDOS versions 		*/

#ifndef QDOS
#undef HW_FPU
#endif /* QDOS */

#ifdef MOTOROLA
/*	 Definitions for Motorola syntax	*/

#define REM 	#
#define SECTION section
#define XDEF	xdef
#define XREF	xref
#define EQU 	equ
#define OX		$
#define END 	end

#define TEXT	text
#define ROM 	rom
#define DATA	data
#define BSS 	bss
#define UDATA	udata

#endif /* MOTOROLA */

#ifdef	ACK
/*	 Definitions for ACK syntax */

#define REM 	;
#define SECTION .sect  
#define XDEF	.globl
#define XREF	.extern
#define EQU 	=
#define OX		0x
#define END    

#define TEXT	.text
#define ROM 	.rom
#define DATA	.data
#define BSS 	.bss
#define UDATA	.udata

#endif /* ACK */

/*	 Special constants used in many places	*/

BIAS4	EQU 	0x7F-1
BIAS8	EQU 	0x3FF-1
BIAS12	EQU 	0x3FFF-1

/*	 Standard XREF references to other internal library routines	*/

	XREF	.Xnorm4
	XREF	.Xnorm8
	XREF	.Xnorm12

	XREF	.overflow
	XREF	.divzero
	XREF	.setmaxmin

#ifdef HW_FPU

/*
*	Define any special routines needed at the
*	operating system level to control access
*	the the FPU.
*/
/*---------------------------------------------------------
*	Settings for use with QDOS
*/
#define FPU_CHECK	 jsr  __FPcheck 	 /* Check if FPU there and usable  */
#define FPU_RELEASE 

/*	 Signal values	*/
SIG_FPE 	EQU    8
/*	 Error Codes	*/
EDOM		EQU    33
ERANGE		EQU    34
/*---------------------------------------------------------*/
#else /* HW_FPU */
EDOM		EQU    33
ERANGE		EQU    34
#endif /* HW_FPU */
