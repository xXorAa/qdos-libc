#
/*
 * strpbrk - find first occurrence of any char from breakat in s
 *           found char, or NULL if none
 *
 *  If CSTRING is not defined, then assembler version is used.
 *  N.B.  Not portable to other processor types or other pointer sizes
 */

#ifdef CSTRING
/*-------------------------  C version --------------------------------*/

#include <string.h>

char *strpbrk(s, breakat)
char *s;
char *breakat;
{
    char *sscan;
    char *bscan;

    for (sscan = s; *sscan != '\0'; sscan++) {
        for (bscan = breakat; *bscan != '\0';)	/* ++ moved down. */
            if (*sscan == *bscan++)
                return((char *)sscan);
    }
    return(NULL);
}

#else
/*-------------------------- M68000 Assembler version -----------------------*/
#if (TARGET == M68000)

; AMENDMENT HISTORY
; ~~~~~~~~~~~~~~~~~
;   07 Nov 93   DJW   - Added underscore to entry point

#include    <limits.h>
#if (INT_MAX == SHRT_MAX)
#define LN w
#define LEN 2
#else
#define LN l
#define LEN 4
#endif

    .globl  _strpbrk

    .text

_strpbrk:
    move.l  a5,-(a7)        /* save register */
    move.l  4+4(a7),a1      /* get s */
    move.l  8+4(a7),a0      /* get breakat */
I1_5:
    move.b  (a1)+,d0        /* *s */
    beq     I1_2            /* EOS of s ? */
    move.l  a0,a5           /* breakat is changed in the inner loop */
I1_9:
    move.b  (a5)+,d1        /* *breakat++ */
    beq     I1_5            /* EOS of breakat ? */
    cmp.b   d0,d1
    bne     I1_9            /* *s != *breakat ? try next */
    subq.l  #1,a1           /* s is one to far */
    move.l  a1,d0           /* return s */
    bra     I1_1
I1_2:
    moveq   #0,d0           /* return NULL */
I1_1:
    move.l  (a7)+,a5        /* restore register */
    rts
#endif /* TARGET ==- M68000 */
#endif



