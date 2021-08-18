;
;    a s c t i m e
;
;   Dummy wrapper as part of implementing name hiding
;   within the C68 libraries.
;
    .text
    .globl  _asctime

_asctime:
    jmp     __Asctime

