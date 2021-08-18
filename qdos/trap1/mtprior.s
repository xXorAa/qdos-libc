;
;   m t _ p r i o r / s m s _ s p j b
;
; routine to set the priority of a job. returns old priority or
; negative error number. equals c routine
;
;   int  mt_prior( jobid_t jobid, unsigned char new_priority)
;
; AMENDMENT HISTORY
; ~~~~~~~~~~~~~~~~~
;   10 Jul 93   DJW   - Removed setting of _oserr.  Merely return QDOS
;                       error code on failure.
;   20 Jul 93   DJW   - Added SMS name as additional entry point
;                     - Changed link/ulnk to use a5 instead of a6
;
;   06 Nov 93   DJW   - Added underscore to entry point names
;                     - Allow for fact that parameters of type 'char' are
;                       now passed as 2 bytes and not 4 bytes
;
;   24 Jan 94   DJW   - Added (yet another) underscore to entry point names
;                       for name hiding purposes

    .text
    .even

    .globl __mt_prior
    .globl __sms_spjb

; locals and their offsets from a6

oldp    equ -16
nextjob equ -12
topjob  equ -8
dummy   equ -4

WORKLEN equ 16              ; size of stack workspace

__mt_prior:                       ; QDOS name
__sms_spjb:                       ; SMS name
    link    a5,#-WORKLEN        ; space for locals
    move.l  d2,-(a7)            ; save corrupted reg
    move.l  8(a5),topjob(a5)    ; set topjob equal to jobid
    move.l  8(a5),nextjob(a5)   ; set nextjob equal to jobid
    pea.l   dummy(a5)           ; address of dummy
    pea.l   oldp(a5)            ; address of old priority
    pea.l   topjob(a5)          ; address of top job
    pea.l   nextjob(a5)         ; address of nextjob
    jsr     __mt_jinf           ; get info on this job
    add.l   #16,a7              ; unstack params
    tst.l   d0                  ; OK ?
    bne     fin                 ; ... NO, call failed
    moveq.l #$b,d0              ; byte code for call
    move.l  8(a5),d1            ; job id
    moveq.l #0,d2
    move.b  13(a5),d2           ; new priority
    trap    #1
    tst.l   d0                  ; OK ?
    bne     fin                 ; ... NO, exit with error code
    move.l  oldp(a5),d0         ;  ...YES, put old priority in d0 for return
fin:
    move.l  (a7)+,d2
    unlk    a5
    rts

