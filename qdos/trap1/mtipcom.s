;
;   m t _ i p c o m / s m s _ h d o p
;
; routine to send a command to the second processor.
; equals c routine,
;   int mt_ipcom( char *param )
;
; AMENDMENT HISTORY
; ~~~~~~~~~~~~~~~~~
;   10 Jul 93   DJW   - Changed code for getting return value to a more
;                       compact variant.
;   20 Jul 93   DJW   - Added SMS name as additional entry point
;                     - Removed link/ulnk instruction by making all
;                       parameter access relative to a7
;
;   06 Nov 93   DJW   - Added underscore to entry point names
;
;   24 Jan 94   DJW   - Added (yet another) underscore to entry point names
;                       for name hiding purposes

    .text
    .even
    .globl __mt_ipcom
    .globl __sms_hdop

SAVEREG equ 12                  ; size of saved registers

__mt_ipcom:                       ; QDOS name
__sms_hdop:                       ; SMS name
    movem.l d5/d7/a3,-(a7)      ; save registers corrupted by call
    moveq.l #$11,d0             ; byte code
    move.l  4+SAVEREG(a7),a3    ; param pointer
    trap    #1
    moveq   #0,d0               ; clear d0 
    move.b  d1,d0               ; return parameter
    movem.l (a7)+,d5/d7/a3      ; restore registers corrupted by call
    rts

