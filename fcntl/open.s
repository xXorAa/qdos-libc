;
;    o p e n
;
;   Dummy wrapper as part of implementing name hiding
;   within the C68 libraries.
;
;   AMENDMENT HISTORY
;   ~~~~~~~~~~~~~~~~~
;   31 Dec 94   DJW   - Amended to go via _Open vector
;
;   24 Feb 96   DJW   - Amended to use new __OpenVector name for vector

    .text
    .globl  __open

__open:
    move.l  __OpenVector,a0     ; get vector value
    jmp     (a0)                ; ... and follow it

