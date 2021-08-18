;
;               g e t _ s y s v a r
;
;   Routine that gets the address of the system variables.  If they
;   are already known, then uses that value.  Otherwise gets the
;   value by issuing the appropriate trap call.
;
;   Euivalent to C routine:
;
;       char * get_sysvar (void)
;
;
; AMENDMENT HISTORY
; ~~~~~~~~~~~~~~~~~
;   06 Nov 93   DJW   - First version.
;                       Developed to remove the need for a number of library
;                       routines to access the global variable containing 
;                       the system variables.  This will make it possible
;                       to put them into run-time link libraries.

    .text
    .even
    .globl  _get_sysvar

sysvar:
    .data4  0

_get_sysvar:
    move.l  sysvar,d0           ; do we already know answer ?
    beq     unknown             ; ... NO, we better go find out
    rts

unknown:
    movem.l d1/d2/a0,-(sp)
    moveq   #0,d0
    trap    #1
    move.l  a0,sysvar
    move.l  a0,d0
    movem.l (sp)+,d1/d2/a0
    rts

