;
;    d u p 2
;
;   Dummy wrapper as part of implementing name hiding
;   within the C68 libraries.
;
    .text
    .globl  _dup2

_dup2:
    jmp     __Dup2

