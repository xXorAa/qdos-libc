#
/*
 * strcoll.c
 *
 * Compares the strings s1 and s2 in light of the current locale setting 
 * WARNING: This is a bogus implementation, since I have no idea what
 *          ANSI is prattling about with respect to locale.
 *
 *  If CSTRING is not defined, then assembler version is used
 *   N.B. The assembler is not portable to other processor types,
 */

#ifdef CSTRING
/*-------------------------- C version ---------------------------*/

#include <string.h>

int strcoll(s1, s2)
char *s1;
char *s2;
{
  return strcmp(s1, s2);
}

#else
/*-------------------------- M68000 Assembler version ----------------------*/
#if (TARGET == M68000)

; AMENDMENT HISTORY
; ~~~~~~~~~~~~~~~~~
;   07 Nov 93   DJW   - Added underscore to entry point

#include <limits.h>

#if (INT_MAX == SHRT_MAX)
#define LN w
#define LEN 2
#else
#define LN l
#define LEN 4
#endif

    .globl _strcoll

    .text

_strcoll:
    jmp     _strcmp

#endif /* TARGET == M68000 */

#endif

