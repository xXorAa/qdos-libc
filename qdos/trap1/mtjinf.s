;
;   m t _ j o b i n f / s m s _ i n j b
;
; routine to return information on a job
; equal to c routine
;
;   int mt_jinf( long *jobid, long *topjob, long *jobp, char **jobloc)
;
; AMENDMENT HISTORY
; ~~~~~~~~~~~~~~~~~
;   10 Jul 93   DJW     Removed setting of _oserr.  Merely return the
;                       QDOS error code instead.
;   20 Jul 93   DJW   - Added SMS name as additional entry point
;                     - Removed link/ulnk instruction by making all
;                       parameter access relative to a7
;   02 Sep 93   DJW   - Added check that none of the pointers passed as
;                       parameters are NULL as this can have disastrous
;                       consequences.
;
;   06 Nov 93   DJW   - Added underscore to entry point names
;
;   24 Jan 94   DJW   - Added (yet another) underscore to entry point names
;                       for name hiding purposes
;   01 Sep 94   DJW   - There was a redundant test of the job id address after
;                       the trap instruction.  Reported by Eric Slagter.

    .text
    .even
    .globl __mt_jinf
    .globl __sms_injb

SAVEREG equ 16+4                ; size of saved registers + return address

__mt_jinf:                        ; QDOS name
__sms_injb:                       ; SMS name
    movem.l d2/d3/a2/a3,-(a7)
    tst.l   0+SAVEREG(a7)       ; Check no parameters are NULL for safety
    beq     err_bp
    tst.l   4+SAVEREG(a7)
    beq     err_bp
    tst.l   8+SAVEREG(a7)
    beq     err_bp
    tst.l   12+SAVEREG(a7)
    beq     err_bp
    moveq.l #2,d0               ; byte code
    move.l  0+SAVEREG(a7),a2    ; jobid address
    move.l  (a2),d1             ; actual jobid
    move.l  4+SAVEREG(a7),a3    ; topjob address
    move.l  (a3),d2             ; actual topjob
    trap    #1
    tst.l   d0                  ; OK ?
    bne     err                 ; ... NO, exit with error code
    move.l  d1,(a2)             ; new jobid
    move.l  d2,(a3)             ; new topjob
    move.l  8+SAVEREG(a7),a2    ; address of job priority figure
    move.l  d3,(a2)             ; save suspended/priority value
    move.l  12+SAVEREG(a7),a2
    move.l  a0,(a2)             ; location of job
err:
    movem.l (a7)+,d2/d3/a2/a3
    rts
err_bp:
    moveq   #-15,d0
    bra     err

