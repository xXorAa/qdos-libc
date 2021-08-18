;
;    a b o r t
;
;   Dummy wrapper as part of implementing name hiding
;   within the C68 libraries.
;
    .text
    .globl  _abort

_abort:
    jmp     __Abort

