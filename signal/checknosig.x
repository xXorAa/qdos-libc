;
;       c h e c k n o s i g
;
;   This routine is used when SIGNAL support has been
;   suppressed for a program.   It is used to satisfy
;   calls that have to be present, and that would do
;   something if signal support was loaded.

    .globl  __CheckSig

__CheckSig:
    move.l  #0,d0
    rts


