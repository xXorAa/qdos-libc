;
;   This is the default vector for program initialisation
;
;   It is is set to point to the _Cinit routine.
;

    .globl  __Cstart

__Cstart:
    dc.l    __Cinit

