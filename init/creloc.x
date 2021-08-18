#
;
;			c r e l o c _ x
;
;	Code for use in C68 startup modules that handles relocation.
;	Used whenever the program is not going to use the RLM.
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
;  25 Sep 99 DJW  - Split relocation code into its own module to make it
;					easier to produce variants of the start-up code that
;					use the RLM instead for this purpose.
;				  - Added changes to handle both LD v1 and LD v2 formats.
;----------------------------------------------------------------------------

;	This pointer is used to find the start of the BSS area.  Before
;	it is "relocated" it will contain the offest to the BSS area.
;	After that it will contain the address of the BSS area.

RELOCSTART:
	dc.l	RELOC_START 	; Start of RELOC area (relocation info for LD v2)
UDATASTART:
	dc.l	UDATA_START 	; Start of UDATA area (relocation info for LD v1)

;*************************************************************************
;
;	Start of real code area
;
;*************************************************************************

START:

	bsr 	__CacheFlush			; Flush caches if present

	lea 	__progbase(pc),a1		; Start of job in memory
	move.l	a1,d1					; save it in d1
	add.l	RELOCSTART(pc),a1		; Get start of RELOC area
	cmpi.l	#$3C3C5245,(a1) 		; Does it start with <<RELOC> tag
	bne 	LDv1					; ... NO - assume LDv1
	addq.l	#8,a1					; Position after tag
	bra 	DO_RELOC
LDv1:
	move.l	d1,a1					; Restore A1
	add.l	UDATASTART(pc),a1		; start of relocation info
DO_RELOC:

#ifdef GST
#include	"relocGST.x"
#else
#include	"relocLD.x"
#endif

	bsr 	__CacheFlush		; Flush caches if present

	move.l	#MT.INF,d0
	trap	#1
	move.l	a0,__sys_var	; save address of global variables
