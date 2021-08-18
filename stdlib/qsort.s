;
;    q s o r t
;
;   Dummy wrapper as part of implementing name hiding
;   within the C68 libraries.
;
    .text
    .globl  _qsort

_qsort:
    jmp     __Qsort

