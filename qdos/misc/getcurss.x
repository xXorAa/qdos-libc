;
;       g e t c u r s
;
;   Routine to get the state of the cursor in a window.
;
;   Equivalent to C routine:
;
;     int _getcurss(chanid_t chanid);
;
;   Returns:
;       -ve     Error occured, or cursor invisible 
;        0      Cursor off
;       +ve     Cursor on
;
;   AMENDMENT HISTORY
;   ~~~~~~~~~~~~~~~~~
;   ??          EAJ   - First version by Erlang Jacobsen
;
;   10 Jun 94   DJW   - Tidied up code to use symbolic constants, etc
;                     - Removed need for link/unlk by access the parameters
;                       directly from the stack.
;

    .text
    .even
    .globl __getcurss


IOW.XTOP equ $09

SD_CURF equ $43

SAVEREG  equ 24+4

getcurss:
    moveq.l #0,d1
    move.b  SD_CURF(a0),d1
    moveq   #0,d0
    rts

__getcurss:
    movem.l d2-d4/a2-a4,-(a7)

    moveq.l #IOW.XTOP,d0
    move.l  0+SAVEREG(a7),a0
    lea     getcurss(pc),a2
    moveq.l #-1,d3
    trap    #3
    tst.l   d0                      ; call OK ?
    bne     qq                      ; ... NO, return error code
    move.l  d1,d0                   ; ... YES, set cursor state as return value
qq:
    movem.l (a7)+,d2-d4/a2-a4
    rts

