;
;   m t _ r e kl j b / s m s _ u s j b
;
; routine to release a suspended job
; equal to c routine
;
;   char *mt_reljb( jobid )
;
; returns:
;       success     address of job header
;       failure     (negative) QDOS error code
;
; AMENDMENT HISTORY
; ~~~~~~~~~~~~~~~~~
;   10 Jul 93   DJW     Removed setting of _oserr on failure - merely
;                       return the QDOS error code.
;   20 Jul 93   DJW   - Added SMS name as additional entry point
;
;   06 Nov 93   DJW   - Added underscore to entry point names
;
;   24 Jan 94   DJW   - Added (yet another) underscore to entry point names
;                       for name hiding purposes

    .text
    .even

    .globl __mt_reljb
    .globl __sms_usjb

__mt_reljb:                   ; QDOS name
__sms_usjb:                   ; SMS name
    moveq.l #9,d0           ; byte code for release job
    move.l  4(a7),d1        ; jobid
    trap    #1
    tst.l   d0              ; OK ?
    bne     err             ; ... NO, exit with error code
    move.l  a0,d0           ; ... YES. set job header address
err:
    rts
