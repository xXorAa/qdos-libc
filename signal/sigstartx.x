;
;   S i g I n i t v X
;
;   This is a dummy version of the signal initialisation
;   vector that is called (via __SigStart()) from the
;   C startup code to indicate that there is no need to
;   initialise the signal handling sub-system.
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

    .globl  __SigInitVector;

__SigInitVector:
    dc.l    0

