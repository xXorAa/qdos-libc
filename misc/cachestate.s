/*
 *  c a c h e s t a t e
 *
 *  Routine to return the status of the cache register.
 *
 *  Equivalent to C function:
 *
 *      long  cache_state (void)
 *
 *  Returns:
 *          -1      Processor does not support cacheing (i.e. less than 68030)
 *
 *          other   Value of the CACR.
 *                  The interpretation of this is processor dependant
 *
 *  AMENDMENT HISTORY
 *  ~~~~~~~~~~~~~~~~~
 *  17 Nov 93   DJW   - First version
 *
 *  21 Jul 98   DJW   - Changed to use _super() and _superend() routines.
 */
    .text
    .even

    .globl _cache_state

_cache_state:
    moveq   #-1,d0              ; preset answer to failure
    move.l  __sys_var,a0        ; get system variables address
    move.b  $a1(a0),d1          ; get variable giving processor details
    cmp.b   #$30,d1             ; is it 68030 or better ?
    bmi     fin                 ; ... NO, then give up

    jsr     __super             ; go into supervisor mode
    dc.l    $4e7a0002
;   MOVEC   CACR,d0             ; get current CACR reg into d0
    jsr     __superend          ; back to user mode (d0 NOT smashed)
fin:
    rts

