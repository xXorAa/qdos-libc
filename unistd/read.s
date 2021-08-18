;
;    r e a d
;
;   Dummy wrapper as part of implementing name hiding
;   within the C68 libraries.
;
    .text
    .globl  _read

_read:
    jmp     __Read

