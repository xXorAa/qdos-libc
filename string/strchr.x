#
/*
 *      s t r c hg r
 *     ( i n d e x )
 *
 *  strchr() = ANSI form.       index() = BSD form.
 *
 *  Return a pointer to the first occurence of <symbol> in <string>.
 *  NULL is returned if <symbol> is not found.
 *
 *  If CSTRING is not defined, then the assembler version is used.
 *  N.B. This is not portable to other processor types
 */

#ifdef CSTRING
/*------------------------- C Version -----------------------------*/

char *strchr(s, charwanted)     /* found char, or NULL if none */
char *s;
char charwanted;
{
  char *scan;

  /* The odd placement of the two tests is so NUL is findable. */
  for (scan = s; *scan != charwanted;)  /* ++ moved down for opt. */
    if (*scan++ == '\0') return((char *) NULL);
  return((char *) scan);
}
#else
#if (TARGET == M68000)
/*---------------------------- 68000 Assembler version ---------------------*/

; AMENDMENT HISTORY
; ~~~~~~~~~~~~~~~~~
;   07 Nov 93   DJW   - Added underscore to entry point

    .text
    .globl _strchr
    .globl _index

#include    <limits.h>
#if (INT_MAX == SHRT_MAX)
#define MOVE_ move.w
#define LEN 2
#else
#define MOVE_ move.l
#define LEN 4
#endif

_strchr:
_index:
    move.l  4(a7),a0        ; string
    MOVE_   8(a7),d0        ; character to find (in right hand byte)
strchr1:
    cmp.b   (a0),d0
    bne     strchr2
    move.l  a0,d0           ; Set found return
    rts
strchr2:
    tst.b   (a0)+
    bne     strchr1
    moveq   #0,d0           ; Set NULL return
    rts
#endif /* TARGET == M68000 */

#endif
