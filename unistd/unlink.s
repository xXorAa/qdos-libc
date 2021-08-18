;
;    u n l i n k
;
;   Dummy wrapper as part of implementing name hiding
;   within the C68 libraries.
;
    .text
    .globl  _unlink

_unlink:
    jmp     __Unlink

