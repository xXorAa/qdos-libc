#
/*
 *              s t r c p y
 *
 *  Copy a string
 *
 *  If CSTRING is not defined, then assembler version is used
 *   N.B. The assembler is not portable to other processor types,
 */

#ifdef CSTRING
/*------------------------------- C Version -------------------------------*/

char *strcpy(dest, source)
char *dest, *source;
{
  char *p = dest;

  while(*dest++ = *source++)
      ;
  return(p);
}

#else
/*-------------------------- M68000 Assembler version --------------------*/
#if (TARGET == M68000)

; AMENDMENT HISTORY
; ~~~~~~~~~~~~~~~~~
;   07 Nov 93   DJW   - Added underscore to entry point
;
;   17 Nov 93   DJW   - Preset d0 reply - this knocked out an instruction
;
;   01 Oct 94   DJW   - Added extra underscore and made names mixed case as
;                       part of implementing name hiding.

#include <limits.h>

#if (INT_MAX == SHRT_MAX)
#define LN w
#define LEN 2
#else
#define LN l
#define LEN 4
#endif

    .text
    .globl __StrCpy

__StrCpy:
    move.l  4(a7),a1        ; destination
    move.l  8(a7),a0        ; source
    move.l  a1,d0           ; preset destination as reply in d0
strcpy1:
    move.b  (a0)+,(a1)+     ; copy byte
    bne     strcpy1         ; loop, unless byte was zero
    rts
#endif /* M68000 version */

#endif

