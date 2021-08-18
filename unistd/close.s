;
;    c l o s e
;
;   Dummy wrapper as part of implementing name hiding
;   within the C68 libraries.
;
    .text
    .globl  _close

_close:
    jmp     __Close

