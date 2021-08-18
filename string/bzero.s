;
;    b z e r o
;
;   Dummy wrapper as part of implementing name hiding
;   within the C68 libraries.
;
    .text
    .globl  _bzero

_bzero:
    jmp     __Bzero

