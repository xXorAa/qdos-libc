;
;    p u t e n v
;
;   Dummy wrapper as part of implementing name hiding
;   within the C68 libraries.
;
    .text
    .globl  _putenv

_putenv:
    jmp     __Putenv

