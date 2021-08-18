;
;    b c o p y
;
;   Dummy wrapper as part of implementing name hiding
;   within the C68 libraries.
;
    .text
    .globl  _bcopy

_bcopy:
    jmp     __Bcopy

