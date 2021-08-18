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
;   24 Feb 96   DJW   - Amended to be simply a wrapper around the real
;                       vector selection routine

    .text
    .globl  _open

_open:
    jmp     __open

