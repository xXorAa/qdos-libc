;
;   m t _ t r a p v / s m s _ e x v
;
; routine to change the job vector table
; equal to c routine
;   int mt_trapv( long jobid, qlvectable *table)
;
; AMENDMENT HISTORY
; ~~~~~~~~~~~~~~~~~
;   10 Jul 93   DJW     Removed setting of _oserr.  Merely return the
;                       QDOS error code.
;   20 Jul 93   DJW   - Added SMS name as additional entry point
;
;   06 Nov 93   DJW   - Added underscore to entry point names
;
;   24 Jan 94   DJW   - Added (yet another) underscore to entry point names
;                       for name hiding purposes

    .text
    .even

    .globl __mt_trapv
    .globl __sms_exv

__mt_trapv:
__sms_exv:
    moveq.l #7,d0       ; byte code
    move.l  8(a7),a1    ; vector table
    move.l  4(a7),d1    ; jobid
    trap    #1
    rts

