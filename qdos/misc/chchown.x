/*
 *      _ c h _ c h o w n
 *
 *  routine to change the owning job of a channel
 *
 *      int _ch_chown( chanid_t chid, jobid_t jobid)
 *
 *  jobid may be -1 for current job.
 *
 *  returns:
 *      success     0
 *      failure     QDOS error code (which is negative)
 *
 *  Amendment History:
 *  ~~~~~~~~~~~~~~~~~
 *  10 MAY 93   DJW   - Reworked code to avoid unecessary jumps
 *
 *  10 Jul 93   DJW   - Removed link/ulnk instructions by making parameter
 *                      access relative to a7
 *                    - Removed setting of _oserr variable.  Now returns
 *                      the QDOS error code (which is negative) on failure
 *
 *  06 Nov 93   DJW   - Added undersocre to entry point name
 *
 *  21 Jul 98   DJW   - Changed to user _super() and _superend() routines
 */

    .text
    .even
    .globl __ch_chown

CHN_OWNR equ $08

SMS.INJB equ $02

SAVEREG  equ 20+4           ; size of saved registers + return address

__ch_chown:
    movem.l d2-d4/a3-a4,-(a7)   ; save registers used in this routine
    move.l  0+SAVEREG(a7),d3    ; get chid parameter
    move.l  4+SAVEREG(a7),d4    ; get jobid parameter
    jsr     __super             ; enter supervisor mode
    move.l  d3,-(a7)            ; set channel ID parameter
    jsr     __getcdb            ; get address of channel block or null
    add.l   #4,a7               ; tidy up stack
    tst.l   d0                  ; Did we find channel ?
    bmi     exit                ; ... NO, exit with error code
ok:
    move.l  d0,a4               ; save channel address
    cmp.l   #-1,d4              ; now check if job is -1 (ie. this job)
    bne     checkjob            ; no - do get job trap to see if it is ok
    moveq   #0,d0               ; MT.INF
    trap    #1                  ; ... do it
    move.l  d1,d4               ; Save Job ID
    bra     gotjob              ; Enter loop
checkjob:
    move.l  d4,d1               ; job ID to check
    move.l  d1,d2               ; ... also top of tree
    moveq   #SMS.INJB,d0        ; MT.JINF
    trap    #1                  ; ... do it
    tst.l   d0                  ; OK ?
    bne     exit                ; ... NO, error exit
gotjob:
    move.l  d4,CHN_OWNR(a4)     ; Store new required job ID in channel block
    moveq   #0,d0               ; set good reply
exit:
    jsr     __superend          ; exit this level of supervisor mode
    movem.l (a7)+,d2-d4/a3-a4   ; Restore saved registers
    rts

