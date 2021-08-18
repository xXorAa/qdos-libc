;
;    w r i t e
;
;   Dummy wrapper as part of implementing name hiding
;   within the C68 libraries.
;
    .text
    .globl  _write

_write:
    jmp     __Write

