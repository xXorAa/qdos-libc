;
;    c h d i r
;
;   Dummy wrapper as part of implementing name hiding
;   within the C68 libraries.
;
    .text
    .globl  _chdir

_chdir:
    jmp     __Chdir

