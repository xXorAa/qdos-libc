;
;   m t _ t r a n s / s m s _ t r n s
;
; QDOS routine to set translation table and error messages
; (only supported from QDOS v1.10 onwards)
;
; equal to C routine
;   int mt_trans( char * trans_table, char * msg_table)
;
; AMENDMENT HISTORY
; ~~~~~~~~~~~~~~~~~
;   25 Jul 93   DJW   - First version
;
;   06 Nov 93   DJW   - Added underscore to entry point names
;
;   24 Jan 94   DJW   - Added (yet another) underscore to entry point names
;                       for name hiding purposes

    .text
    .even

    .globl  __mt_trans        ; QDOS name for call
    .globl  __sms_trns        ; SMS name for call

SAVEREG equ 16+4        ; size of saved registers + return address

__mt_trans:
__sms_trns:
    movem.l d2/d3/a2/a3,-(a7)
    moveq.l #$24,d0                 ; byte code for trap
    move.l  0+SAVEREG(a7),d1        ; pointer to translation table
    move.l  4+SAVEREG(a7),d2        ; pointer to message table
    trap    #1
    movem.l (a7)+,d2/d3/a2/a3
    rts

