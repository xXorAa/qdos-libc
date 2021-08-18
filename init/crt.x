#
;
;           c r t _ x
;
;  Startup code for C68 on the QL
;
; N.B. This file is expected to be passed through
;      the C68 pre-processor to handle the 
;      conditional expansions.
;
;  -DGST       should be define to get a version compatible
;              with the GST linker.   The default is to
;              generate a version compatible with the
;              C68 LD linker.
;
;  Amendment History
;  ~~~~~~~~~~~~~~~~~
;  24 Sep 92 DJW - Added _NDP and _SLASH global variables
;                  (required for future developments)
;
;  28 Mar 93 DJW - Added code to disable any caching before starting the
;                  relocation of the program , and then reset it after.
;                  This is to allow for higher level members of the 690X0
;                  family such as the 68030 (which can be fitted to ST/QL
;                  emulators and the 68040 on the Miracle QXL card)
;
;  14 Jun 93 DJW - Added option to generate a version of the start up code
;                  that is suitable for writing Device Drivers or other code
;                  that is loaded via RESPR.  Does not set up the full C
;                  environment
;
;  22 Aug 93 DJW - The code used for starting/stopping caching changed for
;                  68040 mode to match the CACHE_ON/CACHE_OFF code that is
;                  part of the SMSQ code for the QXL card.
;
;  10 Nov 93 DJW - Corrected problem if d0 not cleared before doing program
;    (v4.10)        relocation.  This caused Atari TT systems to crash!
;
;  31 Jan 94 DJW  - Added some new variables for use with signal handling
;    (v4.13)
;  12 Mar 94 DJW  - Changed start-up processor detection code to allow for
;                   the Super Gold card having its vectors in ROM.
;
;  04 Apr 94 DJW  - Added link to pull in default signal handling table
;                   and code.
;
;  03 Sep 94 DJW  - Added the -DMINIMUM option to allow for the generation 
;                   of a startup module that has absolute minimal support.
;                   This will allow C68 to be used as a super assembler.
;                 - Removed definition of global variables that are not
;                   directly referenced into their own separate files.
;                 - Corrected problem with switching cache back on for 68030s
;                   (Problem reported by PROGS).
;                 - Moved uninitialkised variables into BSS section to reduce
;                   program size.  Changed point at which zeroing starts to
;                   compensate for this.
;                 - Reordered code to move subroutines used by command parsing
;                   routine to be local to that routine.  This slightly
;                   reduces code size.
;                 - Changed program initialisation calls to make use of new
;                   code base on using argunpack() routine.
;                 - Added '_Jobid' to list of variables defined here, and added
;                   code to initialise it.
;
;  01 Oct 94 DJW  - The startup code has been far more modularised as part
;                   of the work to introduce RLL support.  This has happened
;                   at two levels:
;                   1) All code that is specific to intialising the C
;                      environment has been moved to a seperate module that
;                      is called via a vector.  This removes the need to have
;                      seperate versions of the startup code for the case
;                      when the full C environment is not wanted.
;                   2) Certain routines are added to the file via 'include'
;                      statements.  This is to cater for the fact that these
;                      routines are shared by the various start up modules
;                      and the RLM, but we want only one file to maintain.
;
;  10 May 98 DJW  - Now uses CACHEFLUSH instead of CACHE_ON/CACHE_OFF.
;
;  16 May 98 DJW  - CACHEFLUSH renamed to __CacheFlush (makes it visible
;                   from C level) and need for Supervisor mode removed.
;                 - Need to call PROCTYPE removed (similar routine now called
;                   from inside __CacheFlush if required).
;                   C level) and need for setting A6 and Supervisor mode removed.
;                 - No longer get system variables or set supervisor mode
;                   at this level (done by called routines as required)
;
;  25 Sep 99 DJW  - Moved relocation code to own source file.
;                   (part of changes to work with both LDv1 and LDv2 linkers)
;----------------------------------------------------------------------------

    .text    

MT.INF   equ    $00
MT.FRJOB equ    $05
MT.SUSJB equ    $08

;======================================================================
;  Job header
;----------------------------------------------------------------------
    .globl  __progbase

__progbase:
    bra     START(pc)           ; Jump past job header

    dc.l    0                   ; filler to make up to 6 bytes
    dc.w    $4AFB               ; jobe header flag at byte 6
PROGNAME:
    dc.w    6
    dc.b    'C_PROG'
    dc.b    0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

#include    "creloc.x"
#include    "crtjob.x"
#include    "proctype.x"
#include    "cache.x"
#include    "super.x"
#include    "crtdata.x"
