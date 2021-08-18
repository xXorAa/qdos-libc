;
;   m t _ a c t i v / s m s _ a c j b
;
; Routine to activate a job
; equal to c routine
;
;   jobid_t mt_activ( jobid_t jobid, unsigned char priority, timeout_t timeout)
;
; returns either error code from starting job (if timeout was 0) with 
; with _oserr equal to returned error, or error code from new job 
; (if timeout = -1) with _oserr = 0 to signify this is not an error
; in this job
;
; AMENDMENT HISTORY
; ~~~~~~~~~~~~~~~~~
;   20 Jul 93   DJW   - Added SMS name as additional entry point
;                     - Removed link/ulnk instruction by making all
;                       parameter access relative to a7
;   26 Jul 93   DJW   - Added saving a3 as this can be corrupted under
;                       SMS if timeout is -1.
;                     - Removed setting of _oserr.  Changed description
;                       in documentation accordingly.
;
;   06 Nov 93   DJW   - Added underscore to entry point names
;                     - Allow for fact that parameters of type 'char' and 
;                       'short' are now passed as 2 bytes and not 4 bytes
;
;   24 Jan 94   DJW   - Added (yet another) underscore to entry point names
;                       for name hiding purposes

    .text
    .even

    .globl __mt_activ         ; QDOS name for call
    .globl __sms_acjb         ; SMS name for call

SAVEREG equ 16+4        ; size of saved registers + return address

__mt_activ:
__sms_acjb:
    movem.l d2/d3/a2/a3,-(a7)
    moveq.l #$a,d0                  ; byte code for activate
    move.l  0+SAVEREG(a7),d1        ; jobid
    move.b  5+SAVEREG(a7),d2        ; priority
    move.w  6+SAVEREG(a7),d3        ; timeout
    trap    #1
    movem.l (a7)+,d2/d3/a2/a3
    rts

