#
/*
 * strlen - length of string (not including NUL)
 *
 *  If CSTRING is not defined, then assembler version is used
 *   N.B. The assembler is not portable to other processor types,
 */

#ifdef CSTRING
/*------------------------------- C Version -------------------------------*/

#include <string.h>

size_t strlen(scan)
char *scan;
{
    size_t count;

    if (!scan) 
        return 0;
    count = 0;
    while (*scan++ != '\0')
        count++;
    return(count);
}
#else
/*-------------------------- M68000 Assembler version --------------------*/
#if (TARGET == M68000)

; AMENDMENT HISTORY
; ~~~~~~~~~~~~~~~~~
;   07 Nov 93   DJW   - Added underscore to entry point

;;   01 Oct 94   DJW   - Added extra underscore and made names mixed case as
;                       part of implementing name hiding.

#include <limits.h>

#if (INT_MAX == SHRT_MAX)
#define LN w
#define LEN 2
#else
#define LN l
#define LEN 4
#endif

    .globl __StrLen      
    .globl _stclen      /* LATTICE comaptible entry point */

    .text

__StrLen:
_stclen:
    move.l  4(a7),a0    /* get s */
    move.l  a0,d0        /* store s */
I1_3:
    tst.b   (a0)+
    bne     I1_3        /* *s++ == EOS ? no */
    subq.l  #1,a0       /* s is one to far */
    exg     a0,d0
    sub.l   a0,d0       /* return s - old_s */
    rts
#endif /* TARGET == M68000 */

#endif


