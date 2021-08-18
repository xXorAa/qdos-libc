;
;    s t r c a t
;
;   Dummy wrapper as part of implementing name hiding
;   within the C68 libraries.
;
    .text
    .globl  _strcat

_strcat:
    jmp     __StrCat

