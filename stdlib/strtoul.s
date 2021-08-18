;
;    s t r t o u l
;
;   Dummy wrapper as part of implementing name hiding
;   within the C68 libraries.
;
    .text
    .globl  _strtoul

_strtoul:
    jmp     __Strtoul

