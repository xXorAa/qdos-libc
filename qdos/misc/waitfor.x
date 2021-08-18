;
;       w a i t f o r
;
;   Waits for a particular job to finish.
;   Returns -1 if process does not exist.
;   Returns zero if child exited, plus exit code
;   if address is passed for it.
;
;   Equivalent to C routine
;       int waitfor( jobid_t jobid, int *ret_code)
;
; AMENDMENT HISTORY
; ~~~~~~~~~~~~~~~~~
;
;   06 Nov 93   DJW   - Added underscore to entry point names
;
;   16 Nov 93   DJW   - Changed page frame to a5 from a6
;
;   11 Apr 94   EAJ   - reworked completely, see wait and _frkex.
;                       explanations in libc_misc_wait_x.

.extern __waitforjob

    .text
    .even
    .globl _waitfor

_waitfor:
    link    a5,#0
    movem.l d2-d7/a2-a4,-(a7)

    move.l  8(a5),-(a7)
    jsr     __waitforjob
    addq.l  #4,a7

    tst.l   __waittable         ;table set up yet ?
    beq     err                 ;no

l4: moveq   #8,d0               ;wait a bit
    moveq.l #-1,d1
    moveq.l #10,d3
    suba.l  a1,a1
    trap    #1

    move.w  sr,d7
    trap    #0                  ;scan table
    move.l  __waittable,a0
l5: cmpi.l  #-1,(a0)
    beq     notf
    move.l  (a0),d0
    cmp.l   8(a5),d0
    beq     found
    addq.l  #8,a0
    bra     l5

notf:
    move.w  d7,sr
    bra     l4

found:
    move.l  4(a0),d1            ;get ret. code
    clr.l   (a0)                ;clear table entry
    move.w  d7,sr

    moveq.l #0,d0               ;return ok

    move.l  12(a5),d2           ;get pointer to ret_code
    beq     wfq                 ;none, exit now
    move.l  d2,a0
    move.l  d1,(a0)

wfq:
    movem.l (a7)+,d2-d7/a2-a4
    unlk    a5
    rts

err:
    moveq.l #-1,d0
    bra     wfq
