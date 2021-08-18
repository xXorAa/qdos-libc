;
;    s t r l e n
;
;   Dummy wrapper as part of implementing name hiding
;   within the C68 libraries.
;
    .text
    .globl  _strlen

_strlen:
    jmp     __StrLen

