;
;    m e m s e t
;
;   Dummy wrapper as part of implementing name hiding
;   within the C68 libraries.
;
    .text
    .globl  _memmove

_memmove:
    jmp     __MemMove

