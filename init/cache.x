;
;       Cache handling routines
;
;   Support routines used by startup code and RLM
;
;   $Source: win2_LIB_C_INIT_cache_x,v $
;   $Revision: 4.24 $
;
;   AMENDMENT HISTORY
;   ~~~~~~~~~~~~~~~~~
;   10 May 1998  DJW  - Instead of switching caches off, we now simply
;                       flush them.  This should be all that is required!
;   12 May 1998  DJW  - Made CACHEFLUSH self-contained in that it preserves
;                       all registers and makes not assumptions about the
;                       registers on entry.  This makes it easier to call
;                       it from elsewhere.
;   14 Jul 1998  DJW  - Minor changes to use result of ProcessorType() call
;                       instead of re-reading system variable
;   07 Oct 1998  DJW  - Fixed problem for 68030 - a test was wrong meaning
;                       that the 68040 path was inadvertently taken.
;   31 Oct 1998  DJW  - Previous fix could also send 68040 down 68030 path!
;                       Reworked to stop doing this.
;-------------------------------------------------------------------------

;   Use of the CACR (Cache Control Register) is as follows
;   for the different processors (luckily they do not seem
;   to conflict with each other):
;
;   68030:  bit 0   Enable Instruction Cache
;           bit 8   Enable Data cache
;
;           bit 3   Clear Instruction Cache
;           bit 11  Clear Data cache
;
;   68040:  bit 15  Enable Instruction cache
;           bit 31  Enable Data cache
;
;   68060:  bit 15  Enable Instruction cache
;           bit 23  Enable Branch Cache
;           bit 29  Enable Store Buffer
;           bit 31  Enable Data Cache
;
;           bit 21  Clear User entries in branch cache
;           bit 22  Clear All entries in branch cache

    .text

SYS_PRCS  equ   $a1                 ; PRoCeSsor on which system is running
SY.68010  equ   $10
SY.68020  equ   $20
SY.68030  equ   $30
SY.68040  equ   $40

;=======================================================================
;  Cache flush    (68030, 68040 and 68060)
;
;  For processors with caching this will flush the cache.  Used both
;  before and after we do the program relocation.   Whether this is 
;  strictly speaking necessary is depends on exactly what type of caching
;  is in use, (but it is better to be safe than sorry!).
;
;  The code for disabling caching in the QXL uses some system variables
;  to control this cacheing.   These are actually ignored here so that
;  there is no dependency on SMSQ or SMSQ-E.  This should not matter as
;  we are only flushing the caches - not changing their enabled state.
;
;   Assumptions at this point:
;       In User Mode
;       All registers are preserved
;-----------------------------------------------------------------------

    .globl  __CacheFlush

__CacheFlush:
    movem.l d0/d1/d2/a0/a1,-(sp); Save registers we may corrupt
    bsr     __ProcessorType     ; Ensure we know the processor type
    sub.b   #SY.68030,d0        ; Check we have a 68030 or better
    bmi     CACHEFLUSH_RTS      ; ... NO, then simply exit
    bsr     __super             ; Switch to Supervisor mode
    ori.w   #$0700,sr           ; Disable all interrupts
    move.b  CPUTYPE(pc),d0      ; Get CPU type
    sub.b   #SY.68040,d0        ; Check against a 68040
    bmi     CACHEFLUSH_030      ; ... NO - less so it must be a 68030

;   With the 68040 and higher, we have the CPUSH instruction
;   to both push and then invalidate cache contents.

CACHEFLUSH_040:
    dc.w    $f4f8
;   CPUSHA BC                   ; Push and Invalidate both caches
    bra     CACHEFLUSH_END      ; ... and exit

;   On the 68030 we use bits in the CACR to invalidate cache lines

CACHEFLUSH_030:
    dc.l    $4e7a0002
;   MOVEC   CACR,d0             ; read current CACR reg
    move.l  #$00000808,d1       ; Set bits to clear caches
    dc.l    $4e7b1002
;   MOVEC   D1,CACR             ; Clear caches
    dc.l    $4e7b0002           
;   MOVEC   d0,CACR             ; Reset CACR back to original value

CACHEFLUSH_END:
    bsr     __superend

CACHEFLUSH_RTS:
    movem.l (sp)+,d0/d1/d2/a0/a1 ; restore registers corrupted
    rts
