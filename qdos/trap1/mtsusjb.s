;
;   m t _ s u s j b / s m s _ s s j b
;
; routine to suspend a job for a period
;
; Equivalent to C routine
;
;   int mt_susjb( jobid_t jobid, timeout_t time, char *zero)
;
; AMENDMENT HISTORY
; ~~~~~~~~~~~~~~~~~
;   10 Jul 93   DJW     Removed setting of _oserr.  Merely return
;                       QDOS error code.
;
;   20 Jul 93   DJW   - Added SMS name as additional entry point
;                     - Removed link/ulnk instruction by making all
;                       parameter access relative to a7
;
;   06 Nov 93   DJW   - Added underscore to entry point names
;                     - Allowed for fact that parameters of type 'short' are
;                       now passed as 2 bytes and not 4 bytes.
;
;   24 Jan 94   DJW   - Added (yet another) underscore to entry point names
;                       for name hiding purposes

    .text
    .even
    .globl __mt_susjb
    .globl __sms_ssjb

SAVEREG equ 4+4                 ; size of saved registers + return address

__mt_susjb:                       ; QDOS name
__sms_ssjb:                       ; SMS name
    move.l  d3,-(a7)
    moveq.l #8,d0              ; byte code
    move.l  0+SAVEREG(a7),d1   ; jobid
    move.w  4+SAVEREG(a7),d3   ; time to suspend for
    move.l  6+SAVEREG(a7),a1   ; character to zero on job release
    trap    #1
    move.l  (a7)+,d3
    rts

