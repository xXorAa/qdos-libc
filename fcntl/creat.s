;
;    c r e a t
;
;   Dummy wrapper as part of implementing name hiding
;   within the C68 libraries.
;
    .text
    .globl  _creat

_creat:
    jmp     __Creat

