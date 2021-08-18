#
;
;			c r e s p r _ x
;
;	Startup code for C68 module that is to be run as a resident
;	extension rather than as a free-standing program.
;
;	A version of the start-up module that is suitable for programs
;	that are to be started via LRESPR.	This has the following
;	restrictions compared to the full startup
;	 - No stack is allocated (the one of the calling job is used).
;	 - No attempt is made to parse any command line parameters.
;	   (argc and argv are not even set up)
;	 - No attempt is made to set up default channels (it is assumed
;	   that the STDIO package will NOT be used).
;	 - Dynamic memory allocation is not automatically included.
;
;
;  Amendment History
;  ~~~~~~~~~~~~~~~~~
;	01 Oct 94	DJW   - The startup code has been far more modularised as part
;						of the work to introduce RLL support.  This ha happened
;						at two levels:
;					  - All code that is specific to intialising the C
;						environment has been moved to a seperate module that
;						is called via a vector.  This removes the need to have
;						seperate versions of the startup code for the case
;						when the full C environment is not wanted.
;					  - Certain routines are added to the file via 'include'
;						statements.  This is to cater for the fact that these
;						routines are shared by the various start up modules
;						and the RLM, but we want only one file to maintain.
;
;	12 Mar 94	DJW   - Incorporated fixes provided by Erik Slagter to run
;						correctly when LRESPRed from Basic.
;
;  10 May 98 DJW  - Now uses CACHEFLUSH instead of CACHE_ON/CACHE_OFF.
;
;  16 May 98 DJW  - CACHEFLUSH renamed to __CacheFlush (makes it visible
;					from C level) and need for Supervisor mode removed.
;				  - Need to call PROCTYPE removed (similar routine now called
;					from inside __CacheFlush if required).
;					C level) and need for setting A6 and Supervisor mode removed.
;				  - No longer get system variables or set supervisor mode
;					at this level (done by called routines as required)
;
;  25 Sep 99 DJW  - Moved relocation code to own source file.
;					(part of changes to work with both LDv1 and LDv2 linkers)

;----------------------------------------------------------------------------

	.text	 

MT.INF	 equ	$00
SMS.SSJB equ	$08
;
;		Enter here 
;
;************************************************************************
;
;	Start of real code area
;
;************************************************************************

	.globl	__progbase

__progbase:
	bra 	START(pc)

PROGNAME:
	dc.w	6
	dc.b	'CRESPR'


#include "creloc.x"

;======================================================================
;  Start up user code
;  ~~~~~~~~~~~~~~~~~~
;  Finally it is time to call the user code !
;
;----------------------------------------------------------------------

	jmp 	_main			; ======= Call user program =========

#include   "proctype.x"
#include   "cache.x"
#include   "super.x"
#include   "crtdata.x"
