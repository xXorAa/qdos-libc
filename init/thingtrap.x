;
;                       T h i n g T r a p
;
;
;   Library support routine for routines that call the THING system
;   trap.   This routine allows for the fact that on many older systems
;   (such as original QDOS) the TRAP#1 calls to the THING system are
;   not available, and that a call has to be made via a THING vector
;   instead.   This is handled completely transparently.
;
;   On entry, it is assumed that d0-d3 and a0-a3 are set up as though the trap
;   was to be called.
;
; AMENDMENT HISTORY
; ~~~~~~~~~~~~~~~~~
;   24 Jan 94   DJW   - First version.   Based on information from the
;                       QDOS Reference Manual from Jochen Merz, and checked
;                       against methods used in code of THING librarys from
;                       Lester Warehams and Johnathan Hudson.
;
;   13 Apr 94   DJW   - The test for whether to use the vector or trap was
;                       flawed, and the code to go back to user mode was
;                       not correct on all paths.
;
;   14 Sep 94   DJW   - Fixed bug in calling via vector - this stopped
;                       all calls from working on QDOS based systems.
;                     - Removed underscores from start of name.  This makes
;                       it impossible to even call this routine directly
;                       from C by accident.
;                     - Put copy of this code into CRT_X startup module for
;                       use when RLLs are in use.
;
;   21 Jul 98   DJW   - Changed to use get_sysvar for getting system variables.
;                     - Changed to use _super/_superend for supervisor mode.
;
;   13 Oct 00   TG    - Changed so that the vector is used as default instead
;                       of the TRAP (the TRAP is only tried if no vector is
;                       found): this cures the problems with buggy thing TRAP
;                       under some SMSQ/E versions, while working fine on ANY
;                       other QDOS/SMS systems...
;                     - Code optimization and better check for the actual
;                       presence of the thing vector (magic THG% word).

    .text
    .even
    .globl ThingTrap

SMS.INFO    equ     $00         ; trap to get system informatopn
SMS.NTHG    equ     $2b         ; THING trap to get next in list

SYS_THGL    equ     $b8         ; THING list offset in system variables

TH_THING    equ     $10         ; THING base relative to linked list entry
THH_TYPE    equ     $04         ; THING type offset
THH_ENTR    equ     $08         ; THING entry routine pointer

TH_MAGIC    equ     $54484725   ; THG% magic word

ERR.ITNF    equ     -7          ; Error: Not Found
ERR.NIMP    equ     -19         ; Error: Mot Implemented

thing_vector:
    dc.l    0       ; we use this to decide what to do
                    ; 0    = do not know (initial state)
                    ; -ve = TRAP interface available
                    ; +ve = Address of UTILITY THING

ThingTrap:
    move.l  a4,-(sp)                ; save register
    lea     thing_vector(pc),a4     ; address we save vector at
    tst.l   (a4)                    ; see if we know if traps supported
    bpl     check_vector            ; ... NO (or possibly unknown)

;   This is the simplest case - the operating system DOES support
;   the TRAP #1 interface to the THING system.

use_trap:
    move.l  (sp)+,a4                ; restore the saved register
    trap    #1
    tst.l   d0                      ; ensure condition code set
    rts

;   If we get here, the vector interface is to be used or we possibly do not
;   yet know the answer.

check_vector:
    beq     find_vector             ; branch if we don't yet know...

;   We are now calling the THING system via the UTILITY THING.  As a
;   sanity check, we check that our vector still points to it.

use_vector:
    move.l  (a4),a4                 ; get saved thing vector
    cmp.l   #TH_MAGIC,(a4)          ; is this actually a thing ?
    bne     missing                 ; ... apparently not 
    cmp.l   #-1,THH_TYPE(a4)        ; check it is still THING we want
    bne     missing                 ; ... apparently not ?
    move.l  THH_ENTR(a4),a4         ; OK, so entry vector
    jsr     (a4)                    ; ... and take it

rts_cond:
    move.l  (sp)+,a4
    tst.l   d0                      ; ensure condition code set
    rts

;   We don't know yet what interface is to be used...
;   We first check for the presence of the UTILITY THING to call
;   the THING system.

find_vector:
    movem.l d0-d3/a0-a3,-(sp)       ; save registers we might corrupt
    jsr     _get_sysvar             ; get system variables address
    move.l  d0,a0                   ; save in a0
    lea     SYS_THGL(a0),a0         ; this is the THING list link address
    tst.l   (a0)                    ; is the thing list empty ?
    beq     test_trap               ; yes, check for the TRAP existence then...
    jsr     __super                 ; enter Supervisor mode (a0 NOT corrupted)
loop:
    move.l  (a0),d1                 ; get the next thing in the list
    beq     found                   ; end of list.  Should be THING we want
    move.l  d1,a0
    bra     loop                    ; ... and try again
found:
    jsr     __superend              ; exit from supervisor level
    move.l  TH_THING(a0),a0         ; get THING base
    cmp.l   #TH_MAGIC,(a0)          ; is this actually a thing ?
    bne     test_trap               ; no !  Check for the TRAP then...
    cmp.l   #-1,THH_TYPE(a0)        ; is this the thing utility vector ?
    bne     test_trap               ; no !  Check for the TRAP then...

;   The vector has been found.  To avoid the overhead of repeating this check
;   every time, we will save the address.

    lea     thing_vector(pc),a4     ; get address to save vector at
    move.l  a0,(a4)                 ; ... and save result
    movem.l (sp)+,d0-d3/a0-a3       ; restore registers we have corrupted.
    bra     use_vector

;   We try the TRAP #1 interface and see if we get a "Not Implemented" error.
;   If not, then the calls must be available.

test_trap:
    moveq   #SMS.NTHG,d0            ; trap that always works if traps available
    sub.l   a0,a0                   ; ... get first THING in list
    trap    #1                      ; try using trap
    tst.l   d0                      ; did it work?
    movem.l (sp)+,d0-d3/a0-a3       ; first restore saved registers
    bne     missing                 ; there is no thing interface available

;   We have found that the trap interface is available.
;   Therefore set ourselves up to use this immediately on
;   future calls.

    lea     thing_vector(pc),a4     ; set to use trap in future
    subq.l  #1,(a4)                 ; set vector negative to say trap OK
    bra     use_trap                ; go and use trap

;   It appears that there is no support for the THING system loaded.
;   Return an error code.

missing:
    moveq   #ERR.NIMP,d0            ; set not implemented error
    lea     thing_vector(pc),a4     ; get vector address
    clr.l   (a4)                    ; ... and ensure it is cleared
    bra     rts_cond                ; ... and exit
