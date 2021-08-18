;
;    s t r c p y
;
;   Dummy wrapper as part of implementing name hiding
;   within the C68 libraries.
;
    .text
    .globl  _strcpy

_strcpy:
    jmp     __StrCpy

