;
;   S i g C h e c k V
;
;   This is a the signal checking vector that 
;   is called from the _user() routine.
;
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

    .text

    .globl  __SigCheckVector

__SigCheckVector:
    dc.l    0

