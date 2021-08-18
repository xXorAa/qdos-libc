#
;
;           c r t r l l _ x
;
;  Startup code for C68 when using RLL libraries
;
;  Amendment History
;  ~~~~~~~~~~~~~~~~~
;  01 Oct 94    DJW   - Derived from the CRT_X module.
;                     - Utilises the fact that the many of the routines that
;                       are shared between startup mdoules can be added to
;                       this source via #include
;---------------------------------------------------------------------------

    .text    

#if 0				/* as68 is not ready for pc-relative stuff */

MT.INF   equ    $00
RLM.LINK equ    $00             ; RLM Function to link code to a RLL
RLM.RELO equ    $0A             ; RLM Function to do program relocation

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

;************************************************************************
;
;   Start of real code area
;
;************************************************************************

START:

;====================================================================
;  RLL (Runtime Link Library) support
;
;   The RLM is used to:
;       a)  Do the program relocation
;       b)  Link in any needed RLLs.
;
;   If any error occurs durint this process we will have to abandon
;   although we will try and output an error message at least.
;
;--------------------------------------------------------------------

    pea.l   0                       ; NO debug reports
    pea.l   -1                      ; This job is owner
    lea     __progbase(pc),a1       ; Start of job in memory
    move.l  a1,a0                   ; make a copy
    add.l   RELLEN(pc),a1           ; start of relocation info
    move.l  a1,-(sp)                ; address of RLL BSS area
    move.l  a0,-(sp)                ; base address of this code
    moveq   #RLM.RELO,d0            ; relocation required
    bsr     _CallRLM                ; try to execut code
    beq     RELOC_OK                ; ... OK, so
RLM_Error:
    move.l  d0,-(sp)
    lea     $d0,a2                  ; UT.WTEXT vector
    sub.l   a0,a0                   ; to channel 0
    lea     msgRLM(pc),a1           ; message to send
    jsr     (a2)
    move.l  (sp)+,d0
    move.w  $ca,a1                  ; UT.WERSY vector
    jsr     (a1)
    bra     ABORT

msgRLM :    dc.b    0,14,10,' RLM Failure',10
    .even

;   The relocation worked, so now we try to
;   link in RLLs that are required.

RELOC_OK:
    moveq   #RLM.LINK,d0            ; Change operation code to LINK
    bsr     _CallRLM                ; try to execute code
    bne     RLM_Error               ; we have to give up on failure
    lea     18(sp),sp               ; remove parameters from stack

#include    "crtjob.x"

#include    "callRLM.x"
#include    "thingtrap.x"
#include    "super.x"
#include    "crtdata.x"

#endif
