;
;    b c m p
;
;   Dummy wrapper as part of implementing name hiding
;   within the C68 libraries.
;
    .text
    .globl  _bcmp

_bcmp:
    jmp     __Bcmp

