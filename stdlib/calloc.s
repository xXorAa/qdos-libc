;
;    c a l l o c
;
;   Dummy wrapper as part of implementing name hiding
;   within the C68 libraries.
;
    .text
    .globl  _calloc

_calloc:
    jmp     __Calloc

