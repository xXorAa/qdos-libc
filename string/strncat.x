#
/*
 * strncat - append at most n characters of string src to dst
 *
 *  If CSTRING is not defined, then assembler version is used.
 *  N.B.  Not portable to other processor types or other pointer sizes
 */

#ifdef CSTRING
/*-------------------------  C version --------------------------------*/

#include <types.h>
#include <string.h>

char *strncat(dst, src, n)
char *dst;
char *src;
size_t n;
{
    char *dscan, c;
    char *sscan = src;
    long count = n;

    for (dscan = dst; *dscan != '\0'; dscan++)
        continue;
    count = n;
    while ((c = *sscan++) != '\0' && --count >= 0)
        *dscan++ = c;
    *dscan++ = '\0';

    return(dst);
}

#else
/*-------------------------- M68000 Assembler version -----------------------*/
#if (TARGET == M68000)

; AMENDMENT HISTORY
; ~~~~~~~~~~~~~~~~~
;   07 Nov 93   DJW   - Added underscore to entry point

#include    <limits.h>
#if (INT_MAX == SHRT_MAX)
#define MOVE_ move.w
#define SUBQ_ subq.w
#define TST_ tst.w
#define LEN 2
#else
#define MOVE_ move.l
#define SUBQ_ subq.l
#define TST_ tst.l
#define LEN 4
#endif

    .globl  _strncat

    text

_strncat:
    move.l  4(a7),a0        /* get dst */
    move.l  8(a7),a1        /* get src */
    MOVE_   12(a7),d0       /* get n */
I1_5:
    tst.b   (a0)+
    bne     I1_5            /* EOS of dst reached ? */
    subq.l  #1,a0           /* we are one to far */
I1_7:
    move.b  (a1)+,d1        /* *src */
    beq     I1_6            /* EOS of src reached ? */
    TST_    d0
    beq     I1_6            /* n == 0 ? finished */
    SUBQ_   #1,d0
    move.b  d1,(a0)+
    bra     I1_7
I1_6:
    move.b  #0,(a0)+
    move.l  4(a7),d0        /* return dst */
    rts
#endif /* TARGET == M68000 */

#endif


