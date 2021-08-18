#
/*
 * strncmp - compare at most n characters of string s1 to s2
 *
 * <0 for <, 0 for ==, >0 for >
 *
 *  If CSTRING is not defined, then assembler version is used.
 *  N.B.  Not portable to other processor types or other pointer sizes
 */

#ifdef CSTRING
/*-------------------------  C version --------------------------------*/

#include <string.h>
#include <types.h>

int strncmp(scan1, scan2, n)
char *scan1;
char *scan2;
size_t n;
{
    unsigned char c1, c2;
    long count;

    count = n;
    do {
        c1 = (unsigned char)*scan1++;
        c2 = (unsigned char)*scan2++;
    } while (--count >= 0 && c1 && c1 == c2);

    if (count < 0)
        return(0);

    /*
     * The following case analysis is necessary so that characters
     * which look negative collate low against normal characters but
     * high against the end-of-string NUL.
     */
    if (c1 == c2)
        return(0);
    else if (c1 == '\0')
        return(-1);
    else if (c2 == '\0')
        return(1);
/*
    else
*/
        return(c1 - c2);
}

#else
/*-------------------------- M68000 Assembler version -----------------------*/
#if (TARGET == M68000)

; AMENDMENT HISTORY
; ~~~~~~~~~~~~~~~~~
;   07 Nov 93   DJW   - Added underscore to entry point
;
;   28 Aug 94   DJW   - Made changes to treat string as unsigned char as
;                       required by the ANSI standard.  This had the 
;                       desireable effect of shortening the code

#include    <limits.h>
#if (INT_MAX == SHRT_MAX)
#define MOVE_ move.w
#define SUBQ_ subq.w
#define LEN 2
#else
#define MOVE_ move.l
#define SUBQ_ subq.l
#define LEN 4
#endif

    .globl  _strncmp

    .text

_strncmp:
    move.l  4(a7),a0        /* get s1 */
    move.l  8(a7),a1        /* get s2 */
    MOVE_   12(a7),d2       /* get n */
    moveq   #0,d0           /* clear registers */
    moveq   #0,d1
I1_6:
    SUBQ_   #1,d2
    bmi     I1_12           /* n == 0 ?       ** Also assumes d0 == d1 */
    move.b  (a1)+,d1        /* *s2++ */
    move.b  (a0)+,d0
    beq     I1_12           /* *s1++ == EOS ? */
    cmp.b   d1,d0
    beq     I1_6            /* *s1 == *s2 ? try next */

I1_12:
    sub.l   d1,d0           /* return *s1 - *s2 */
I1_1:
    rts
#endif /* TARGET == M68000 */

#endif


