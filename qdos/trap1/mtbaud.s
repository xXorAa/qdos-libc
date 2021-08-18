;
;   m t _ b a u d / s m s _ c o m m
;
; routine to set the baud rate for both serial ports
; equal to c routine
;
;   int mt_baud( long rate )
;
; AMENDMENT HISTORY
; ~~~~~~~~~~~~~~~~~
;   10 Jul 93   DJW   - Removed setting of _oserr (which was not relevant
;                       in any case for this call)
;
;   20 Jul 93   DJW   - Added SMS name as additional entry point
;
;   06 Nov 93   DJW   - Added underscore to entry point names
;
;   24 Jan 94   DJW   - Added (yet another) underscore to entry point names
;                       for name hiding purposes
;
;   10 May 96   DJW   - Changed parameter to long, to allow for higher baud
;                       rates.  Despite the fact that documentation says the
;                       parameter is a word, later systems accept a long.

    .text
    .even
    .globl __mt_baud        ; QDOS name
    .globl __sms_comm       ; SMS name

__mt_baud:
__sms_comm:
    moveq.l #$12,d0         ; byte code
    move.l  0+4(a7),d1      ; baud rate
    trap    #1
    rts

