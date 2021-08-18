;
;    m e m c m p
;
;   Dummy wrapper as part of implementing name hiding
;   within the C68 libraries.
;
    .text
    .globl  _memcmp

_memcmp:
    jmp     __MemCmp

