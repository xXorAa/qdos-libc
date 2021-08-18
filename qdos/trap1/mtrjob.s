;
;   m t _ r j o b   / s m s _ r m j b
;   m t _ f r j o b / s m s _ f r j b
;
; QDOS routines to remove a job
;   - in normal way
;   - with force
;
; Equal to C routines
;
;   int mt_rjob ( jobid_t jobid, int code)
;   int mt_frjob( jobid_t jobid, int code)
;
; AMENDMENT HISTORY
; ~~~~~~~~~~~~~~~~~
;   10 Jul 93   DJW   - Removed setting of _oserr on failure - merely
;                       return QDOS error code.
;   20 Jul 93   DJW   - Added SMS name as additional entry point
;                     - Removed link/ulnk instruction by making all
;                       parameter access relative to a7
;   30 Jul 93   DJW   - Merged mt_frjob() into this source file
;
;   06 Nov 93   DJW   - Added underscore to entry point names
;
;   24 Jan 94   DJW   - Added (yet another) underscore to entry point names
;                       for name hiding purposes

    .text
    .even

    .globl  __mt_rjob         ; QDOS name for call
    .globl  __sms_rmjb        ; SMS name for call
__mt_rjob:
__sms_rmjb:
    moveq   #4,d0
    bra     shared

    .globl __mt_frjob         ; QDOS name for call
    .globl __sms_frjb         ; SMS name for call
__mt_frjob:
__sms_frjb:
    moveq   #5,d0

SAVEREG equ 16+4        ; size of saved registers + return address

shared:
;       d0 already contains trap code required
    movem.l d2/d3/a2/a3,-(a7)
    move.l  0+SAVEREG(a7),d1        ; job id
    move.l  4+SAVEREG(a7),d3        ; error code
    trap    #1
    movem.l (a7)+,d2/d3/a2/a3
    rts

