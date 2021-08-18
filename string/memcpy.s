;
;    m e m c p y 
;
;   Dummy wrapper as part of implementing name hiding
;   within the C68 libraries.
;
    .text
    .globl  _memcpy

_memcpy:
    jmp     __MemCpy

