#
/*
 *  strxfrm.c
 *
 * Transforms s2 into s1.  The effect is to make strcmp() act on the
 * transformed strings exactly as strcoll() does on original strings.
 * WARNING: This is a bogus implementation, since I have no idea what
 *          ANSI is prattling about with respect to locale.
 *
 *  If CSTRING is not defined, then assembler version is used
 *   N.B. The assembler is not portable to other processor types,
 */

#ifdef CSTRING
/*------------------------------- C Version -------------------------------*/

#include <string.h>

size_t strxfrm(s1, s2, n)
char *s1;
char *s2;
size_t n;
{
  strncpy(s1, s2, n);
  return strlen(s2);
}

#else
/*-------------------------- M68000 Assembler version --------------------*/
#if (TARGET == M68000)

; AMENDMENT HISTORY
; ~~~~~~~~~~~~~~~~~
;   07 Nov 93   DJW   - Added underscore to entry point

#include <limits.h>

#if (INT_MAX == SHRT_MAX)
#define MOVE_ move.w
#define LEN 2
#else
#define MOVE_ move.l
#define LEN 4
#endif

    .globl  _strxfrm

    .text

_strxfrm:
    link    a6,#0
    MOVE_   16(a6),-(sp)
    move.l  12(a6),-(sp)
    move.l  8(a6),-(sp)
    jsr     _strncpy
    move.l  12(a6),-(sp)
    jsr     _strlen
    lea     12+LEN(a7),sp           /* Tidy up stack */
    unlk    a6
    rts
#endif /* TARGET == M68000 */
#endif

