#
/*
 * strcat - append string src to dst
 */

#ifdef CTRING
/*----------------------------- C version -----------------------------*/

#include <string.h>

char *strcat(dst, src)
char *dst;
char *src;
{
    char *dscan;
    char *sscan;

    if ((sscan = src)) {
        for (dscan = dst; *dscan != '\0'; dscan++)
            continue;
        while ((*dscan++ = *sscan++) != '\0')
            continue;
    }
    return(dst);
}

#else
/*-------------------------- M68000 Assembler version -----------------------*/
#if ( TARGET == M68000 )

; AMENDMENT HISTORY
; ~~~~~~~~~~~~~~~~~
;   07 Nov 93   DJW   - Added underscore to entry point
;
;   17 Nov 93   DJW   - Saved a few bytes by presetting d0 from a0
;
;   01 Oct 94   DJW   - Added extra underscore and made names mixed case as
;                       part of implementing name hiding.

    .globl __StrCat

    .text

__StrCat:
    move.l  4(a7),a0        ; get dst
    move.l  8(a7),a1        ; get src
    move.l  a0,d0           ; preset reply as destination
I1_5:
    tst.b   (a0)+
    bne     I1_5            ; EOS of dst ?
    subq.l  #1,a0
I1_7:
    move.b  (a1)+,(a0)+
    bne     I1_7
    rts
#endif   /* TARGET == M68000 */

#endif

