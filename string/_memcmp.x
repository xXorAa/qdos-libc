#
/*
 *  memcmp - compare bytes
 *
 *  If CSTRING is not defined, then assembler version is used
 *  N.B. The assembler is not portable to other processor types,
 *
 *  AMENDMENT HISTORY
 *  ~~~~~~~~~~~~~~~~~
 *  01 Oct 94   DJW   - Merged in bcmp() routine into same file.
 */

#ifdef CSTRING
/*----------------------------- C version -------------------------------*/

#include <stddef.h>
#include <string.h>

/* <0, == 0, >0 */

int memcmp(s1, s2, size)
char *s1;
char *s2;
size_t size;
{
    unsigned char *scan1;
    unsigned char *scan2;
    size_t n;

    scan1 = (unsigned char *)s1;
    scan2 = (unsigned char *)s2;
    for (n = size; n > 0; n--)
        if (*scan1 == *scan2) {
            scan1++;
            scan2++;
        } else
            return(*scan1 - *scan2);

    return(0);
}
/*
 *  b c m p
 *
 *  BSD compatible routine to compare memory.
 *  (ANSI uses memcmp instead)
 */

#include <memory.h>

int  bcmp (ptr1, ptr2, len)
char *ptr1;
char *ptr2;
int  len;
{
    return memcmp((void *)ptr1,(void *)ptr2,(size_t)len);
}

#else
/*-------------------------- M68000 Assembler version ---------------------*/
#if (TARGET == M68000)

; AMENDMENT HISTORY
; ~~~~~~~~~~~~~~~~~
;   07 Nov 93   DJW   - Added underscore to entry point
;
;   28 Aug 94   DJW   - Made changes to treat string as unsigned char as
;                       required by the ANSI standard.
;
;   01 Oct 94   DJW   - Merged in bcmp() entry point.
;                     - Added extra underscore as part of implementing
;                       name hiding.


#include <limits.h>

#if (INT_MAX == SHRT_MAX)
#define MOVE_ move.w
#define SUBQ_ subq.w
#else
#define MOVE_ move.l
#define SUBQ_ subq.l
#endif
    .globl  __MemCmp
    .globl  __Bcmp

    .text

__MemCmp:
__Bcmp:
    move.l  4(a7),a0      /* get s1 */
    move.l  8(a7),a1      /* get s2 */
    moveq   #0,d0           /* clear register */
    moveq   #0,d1           /* celar register */
    MOVE_   12(a7),d2     /* get size */
I1_5:
    SUBQ_   #1,d2           /* reduce count */
    bmi     I1_2            /* all bytes tested ? */
    cmpm.b  (a1)+,(a0)+
    beq     I1_5            /* bytes are not equal ? */
I1_7:
    move.b  -(a0),d0
    move.b  -(a1),d1
I1_2:
    sub.l   d1,d0           /* get >0 or <0 */
    rts

#endif /* TARGET == M68000 */

#endif /* CSTRING */

