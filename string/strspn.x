#
/*
 * strspn - find length of initial segment of s consisting entirely
 * of characters from accept
 *
 *  If CSTRING is not defined, then the assembler version is used.
 *  N.B. This is not portable to other processor types
 */

#ifdef CSTRING
/*------------------------- C Version -----------------------------*/

#include <types.h>
#include <string.h>

size_t strspn(s, accept)
char *s;
char *accept;
{
    char *sscan;
    char *ascan;
    size_t count;

    count = 0;
    for (sscan = s; *sscan != '\0'; sscan++) {
        for (ascan = accept; *ascan != '\0'; ascan++)
            if (*sscan == *ascan)
                break;
        if (*ascan == '\0')
            return(count);
        count++;
    }
    return(count);
}
#else
#if (TARGET == M68000)
/*---------------------------- 68000 Assembler version ---------------------*/

; AMENDMENT HISTORY
; ~~~~~~~~~~~~~~~~~
;   07 Nov 93   DJW   - Added underscore to entry point

#include    <limits.h>
#if (INT_MAX == SHRT_MAX)
#define ADDQ_ addq.w
#define LEN 2
#else
#define ADDQ_ addq.l
#define LEN 4
#endif

    .globl _strspn

    .text

_strspn:
    movem.l a5,-(a7)        /* save corrupted registers */
    move.l  4+4(a7),a1      /* get s */
    move.l  4+8(a7),a0      /* get accept */
    moveq   #0,d0           /* count = 0 */
I1_5:
    move.b  (a1)+,d2        /* *s++ */
    beq     I1_1            /* EOS of s ? */
    move.l  a0,a5           /* accept is changed in the inner loop */
I1_9:
    move.b  (a5),d1         /* *accept */
    beq     I1_1            /* EOS of accept ? yes */
    cmp.b   d1,d2
    bne     I1_7            /* *s != *accept ? */
    tst.b   d1
    beq     I1_1            /* EOS of accept ? yes */
    ADDQ_   #1,d0           /* count++ */
    bra     I1_5
I1_7:
    addq.l  #1,a5           /* accept++ */
    bra     I1_9
I1_1:
    movem.l (a7)+,a5        /* restore corrupted registers */
    rts
#endif  /* TARGET == MN68000 */

#endif

