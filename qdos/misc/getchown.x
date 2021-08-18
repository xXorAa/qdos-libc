;
;   _ g e t _ c h o w n
;
; Routine to find the owner of an existing channel
; Equivalent to C routine
;   jobid_t _get_chown( chanid_t chid )
;
; returns:
;       success     job id of owner of channel
;       failure     QDOS error code (which is negative)
;
; AMENDMENT HISTORY
; ~~~~~~~~~~~~~~~~~
;   10 Jul 93   DJW   - Removed dependency on _getcdb() setting _oserr
;
;   06 Nov 93   DJW   - Added underscore to entry point names
;
;   11 Apr 94   EAJ   - Fixed bug (changed bne fin to bmi fin).

    .text
    .even
    .globl __get_chown

CHN_OWNR equ $08

SAVEREG equ 0+4         ; size of saved registers + return address

__get_chown:
    move.l  0+SAVEREG(a7),d0
    move.l  d0,-(a7)
    jsr     __getcdb
    add.l   #4,a7               ; tidy up stack
    tst.l   d0                  ; OK ?
    bmi     fin                 ; ... NO, exit immediately
    move.l  d0,a0               ; get channel block a
    move.l  CHN_OWNR(a0),d0     ; set owner as reply
fin:
    rts

