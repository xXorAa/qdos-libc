#
/*
 * strncpy - copy at most n characters of string src to dst
 *
 *  If CSTRING is not defined, then assembler version is used.
 *  N.B.  Not portable to other processor types or other pointer sizes
 */

#ifdef CSTRING
/*-------------------------  C version --------------------------------*/
#include <types.h>
#include <string.h>

char *strncpy(dst, src, n)
char *dst;
char *src;
size_t n;
{
    char *dscan = dst;
    char *sscan = src;
    long count;

    count = n;
    while (--count >= 0 && (*dscan++ = *sscan++) != '\0')
    {
        continue;
    }
    while (--count >= 0)
    {
        *dscan++ = '\0';
    }
    return(dst);
}

#else
/*-------------------------- M68000 Assembler version -----------------------*/
#if (TARGET == M68000)

; AMENDMENT HISTORY
; ~~~~~~~~~~~~~~~~~
;   07 Nov 93   DJW   - Added underscore to entry point
;
;   11 Oct 98   DJW   - Added a test to do nothing if length negative

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

    .globl  _strncpy

    .text

_strncpy:
    move.l  4(a7),a0        /* get dst */
    move.l  8(a7),a1        /* get src */
    MOVE_   12(a7),d0       /* get n */
    bmi     I1_8            /* do nothing if negative */
I1_3:
    TST_    d0
    beq     I1_9            /* n == 0 ? */
    SUBQ_   #1,d0           /* n-- */
    move.b  (a1)+,(a0)+     /* *dst++ = *src++ */
    bne     I1_3            /* EOS moved ? no */
I1_9:
    TST_    d0
    beq     I1_8            /* n == 0 ? exit */
    SUBQ_   #1,d0
    move.b  #0,(a0)+        /* fill with EOS */
    bra     I1_9
I1_8:
    move.l  4(a7),d0
    rts
#endif /* TARGET == M68000 */
#endif


