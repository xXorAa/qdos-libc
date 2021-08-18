#
/*
 * memchr - search for a byte
 *
 *  If CSTRING is not defined, then assembler version is used
 *  N.B. The assembler is not portable to other processor types,
 */

#ifdef CSTRING
/*--------------------------- C Version -----------------------------*/

#include <stddef.h>
#include <string.h>

/*
 * CHARBITS should be defined only if the compiler lacks "unsigned char".
 * It should be a mask, e.g. 0377 for an 8-bit machine.
 */
#ifndef CHARBITS
#define UNSCHAR(c)  ((unsigned char)(c))
#else
#define UNSCHAR(c)  ((c)&CHARBITS)
#endif

void *memchr(s, ucharwanted, size)
char *s;
int ucharwanted;
size_t size;
{
    char *scan;
    size_t n;
    int uc;

    scan = s;
    uc = UNSCHAR(ucharwanted);
    for (n = size; n > 0; n--)
        if (UNSCHAR(*scan) == uc)
            return((void *)scan);
        else
            scan++;

    return(NULL);
}
#else
/*--------------------------- 68000 Assembler version -------------------------*/
#if ( TARGET == M68000 )

; AMENDMENT HISTORY
; ~~~~~~~~~~~~~~~~~
;   07 Nov 93   DJW   - Added underscore to entry point

#include <limits.h>
#if (INT_MAX == SHRT_MAX)
#define MOVE_ move.w
#define SUBQ_ subq.w
#define LEN 2
#else
#define MOVE_ move.l
#define SUBQ_ subq.l
#define LEN 4
#endif

    .globl _memchr

    .text

_memchr:
    move.l  4(a7),a0    /* get s */
    MOVE_ 8(a7),d1    /* get ucharwanted */
    MOVE_ 8+LEN(a7),d0   /* get size */
I1_5:
    bls     I1_2        /* all bytes tested ? */
    cmp.b   (a0)+,d1    /* compare & s++ */
    beq     I1_7        /* ucharwant found ? */
    SUBQ_ #1,d0       /* size-- */
    bra     I1_5
I1_2:
    moveq   #0,d0       /* return NULL */
    bra     I1_1
I1_7:
    subq.l  #1,a0       /* s is one to far */
    move.l  a0,d0       /* return s */
I1_1:
    rts
#endif /* TARGET == M68000 */

#endif

