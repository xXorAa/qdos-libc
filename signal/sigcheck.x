;
;   _ S i g C h e c k
;
;   This is a the signal checking routine that is called
;   from library routines such as the _user() routine.
;
;   It actually first checks a vector to see
;   if we really have signal checking active.
;   This is a double indirection.   The reason
;   for this is to provide a mechanism that
;   will pull in signal handling code if there
;   are any calls to signals in the program, but
;   not if there are none.
;
;   AMENDMENT HISTORY
;   ~~~~~~~~~~~~~~~~~
;   18 Mar 98   DJW   - First version as part of enhancement to not
;                       include signal handling initialisation code
;                       unless there is at least one call to a
;                       signal routine somewhere within the program.
;
;   20 May 98   DJW   - Fixed problem introduced in the C68 4.24 release
;                       (problem reported by David Gilham)


    .text

    .globl  __SigCheck

__SigCheck:
    move.l  __SigCheckVector,d0     ; get Vector value
    bne     havesig                 ; ... if set we have active signal handling
    rts                             ; ... if not set then exit immediately
havesig:
    move.l  d0,a0                   ; load vector into address register
    jmp     (a0)                    ; call vector (exit via its RTS)

