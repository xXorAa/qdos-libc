/*
*		6 8 k c o n f . h
*
*	Header file that sets up definitions used within the 
*	68K support routines for the C68 compiler.
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
/*	 (and if not set default required	*/

#ifdef AS68
#define ACK
#endif

#ifndef ACK
#ifndef MOTOROLA
#define ACK
#endif /* MOTOROLA */
#endif /* ACK */

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
