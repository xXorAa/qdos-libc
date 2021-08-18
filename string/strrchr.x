#
/*
 *      s t r r c h r
 *     ( r i n d e x )
 *
 * strrchr() = ANSI form.    rindex() = BSD form.
 *
 * Return a pointer to the last occurance of <symbol> in <string>.
 * NULL is returned if <symbol> is not found.
 *
 *  If CSTRING is not defined, then assembler version is used.
 *  N.B.  Not portable to other processor types or other pointer sizes
 */

#ifdef CSTRING
/*-------------------------  C version --------------------------------*/
#include <string.h>

char *strrchr(s, charwanted)    /* found char, or NULL if none */
char *s;
char charwanted;
{
  char *scan;
  char *place;

  place = (char *) NULL;
  for (scan = s; *scan != '\0'; scan++)
    if (*scan == charwanted) place = scan;
  if (charwanted == '\0') return ((char *) scan);
  return((char *) place);
}

#else
/*-------------------------- M68000 Assembler version -----------------------*/
#if (TARGET == M68000)

; AMENDMENT HISTORY
; ~~~~~~~~~~~~~~~~~
;   07 Nov 93   DJW   - Added underscore to entry point

#include    <limits.h>
#if (INT_MAX == SHRT_MAX)
#define MOVE_ move.w
#define LEN 2
#else
#define MOVE_ move.l
#define LEN 4
#endif

    .text
    .globl _strrchr
    .globl _rindex

#include <limits.h>

_strrchr:
_rindex:
    move.l  4(a7),a0
    MOVE_   8(a7),d0 
    move.l  a0,a1
strrchr1:
    tst.b   (a0)+
    bne     strrchr1
strrchr2:
    cmp.b   -(a0),d0
    bne     strrchr3
    move.l  a0,d0
    rts
strrchr3:
    cmp.l   a0,a1
    bne     strrchr2
    moveq   #0,d0
    rts
#endif /* TARGET == M68000 */

#endif

