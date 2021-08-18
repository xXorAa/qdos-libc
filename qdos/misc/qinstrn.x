;   q i n s t r n
;
;   Copyright 1992, HaPeSu (Hans-Peter Sulzer)
;   (name derived from trap io.QIN, for (C-)STRing and for a max. No. of chars)
;   may be included into the C68-compilation system
;   but MUST NOT be included into commercially sold libraries!!!
;
;   function to type in a C-string ('\0'-terminated) into the current
;   keyboard queue (similar to Turbo Toolkit command TYPE_IN)
;
;       int qinstrn(char *str, int max)
;
;   returns no. of chars sent (typed in), if an error has occured
;   the result is negative (the QDOS error code)
;
;   AMENDMENT HISTORY
;   ~~~~~~~~~~~~~~~~~
;   10 Jul 93   DJW     Removed setting of _oserr.  If an error occurs, then
;                       retunrs QDOS error code (which is negative)
;
;   06 Nov 93   DJW   - Added underscore to entry point names

    .globl _qinstrn

    .text

SAVEREG equ 16+4                ; size of saved registers + return address
IO.QIN  equ $e0
SV_KEYQ equ $4c

max = SAVEREG+6

_qinstrn:
    movem.l a2-a5,-(a7)         ; save some regs
    clr.l   d0                  ; MT.INF
    trap    #1
    adda.l  #SV_KEYQ,a0 
    move.l  a0,a4               ; save copy
    move.w  IO.QIN,a5           ; vector io.qin
    move.l  SAVEREG(a7),a1      ; fetch ptr to string
    movea.l a1,a0               ; save copy
    move.w  max(a7),d2          ; fetch max. chars
    bmi     sent                ; trivial, cause no chars to sent
    subq.w  #1,d2               ; for (i=0; i<max;)
    bmi     sent                ; trivial, cause no chars to send

sendbyte:
    move.b  (a1),d1             ; get byte to send (type in)
    beq     sent                ; if end of string ('\0') we are ready
    move.l  (a4),a2             ; get ptr to current keyboard queue
    jsr     (a5)                ;io.qin
    tst.l   d0                  ; OK ?
    bne     fin                 ;   oops, exit with error code
    addq.l  #1,a1               ; next byte
    dbf     d2,sendbyte         ; next char if not already max chars sent

sent:
    suba.l  a0,a1               ; compute no. of bytes sent (typed in)
    move.l  a1,d0               ; return result
fin:
    movem.l (a7)+,a2-a5
    rts

; /* Test-prog for qinstrn */
; #include <stdio.h>
; #include <stdlib.h>
;
; int main(void);
; int qinstrn(char *str,short n);
;
; char test[256];
;
; int main(){
; int e;
; kbhit());     /* switch current keyboard queue to "our" channel */
; e=qinstrn("Hello, world",(short)20);
; gets(test);
; return e;
; }

