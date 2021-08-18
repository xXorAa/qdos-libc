#
/*
 * strcspn - find length of initial segment of s consisting entirely
 * of characters not from reject
 *
 *  If CSTRING is not defined, then assembler version is used
 *   N.B. The assembler is not portable to other processor types,
 */

#ifdef CSTRING
/*------------------------------ C version ---------------------------------*/

#include <types.h>
#include <string.h>

size_t strcspn(s, reject)
char *s;
char *reject;
{
    char *scan;
    char *rscan;
    size_t count;

    count = 0;
    for (scan = s; *scan != '\0'; scan++) {
        for (rscan = reject; *rscan != '\0';)	/* ++ moved down. */
            if (*scan == *rscan++)
                return(count);
        count++;
    }
    return(count);
}

#else
/*--------------------------- M68000 Assembler vesion ---------------------------*/
#if (TARGET == M68000)

; AMENDMENT HISTORY
; ~~~~~~~~~~~~~~~~~
;   07 Nov 93   DJW   - Added underscore to entry point

#include <limits.h>

#if (INT_MAX == SHRT_MAX)
#define ADDQ_ addq.w
#define LEN 2
#else
#define ADDQ_ addq.l
#define LEN 4
#endif

    .globl  _strcspn

    .text

_strcspn:
    move.l  4(a7),a0        /* get s */
    move.l  8(a7),a1        /* get reject */
    move.l  a5,-(a7)        /* Save register */
    moveq   #0,d0           /* count = 0 */
I1_5:
    move.b  (a0)+,d1        /* *s++ */
    beq     I1_2
    move.l  a1,a5           /* reject is changed in the inner loop */
I1_7:
    tst.b   (a5)
    beq     I1_6            /* EOS of reject ? */
    cmp.b   (a5)+,d1
    bne     I1_7            /* *s != *reject ? */
I1_2:
    move.l  (a7)+,a5        /* Restore saved register */
    rts
I1_6:
    ADDQ_   #1,d0
    bra     I1_5
#endif /* TARGET == M68000 */

#endif

