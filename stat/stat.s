;
;    s t a t
;
;   Dummy wrapper as part of implementing name hiding
;   within the C68 libraries.
;
    .text
    .globl  _stat

_stat:
    jmp     __Stat

