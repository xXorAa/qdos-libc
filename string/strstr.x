#
/*
 * strstr - find first occurrence of wanted in s
 *          found string, or NULL if none
 *
 *  If CSTRING is not defined, then the assembler version is used.
 *  N.B. This is not portable to other processor types
 */

#ifdef CSTRING
/*------------------------- C Version -----------------------------*/

#include <string.h>

char *strstr(s, wanted)
char *s;
char *wanted;
{
    char *scan;
    size_t len;
    char firstc;
    int strcmp();
    size_t strlen();

    /*
     * The odd placement of the two tests is so "" is findable.
     * Also, we inline the first char for speed.
     * The ++ on scan has been moved down for optimization.
     */
    firstc = *wanted;
    len = strlen(wanted);
    for (scan = s; *scan != firstc || strncmp(scan, wanted, len) != 0; )
        if (*scan++ == '\0')
            return(NULL);
    return((char *)scan);
}

#else
#if (TARGET == M68000)
/*---------------------------- 68000 Assembler version ---------------------*/

; AMENDMENT HISTORY
; ~~~~~~~~~~~~~~~~~
;   07 Nov 93   DJW   - Added underscore to entry point

.text
.globl strchr
.globl index

#include    <limits.h>
#if (INT_MAX == SHRT_MAX)
#define MOVE_ move.w
#define LEN 2
#else
#define MOVE_ move.l
#define LEN 4
#endif

    .globl  _strstr

    .text

_strstr:
    movem.l d6/d7/a5/a4,-(sp)
    move.l  16+4(a7),a5         /* get s */
    move.l  16+8(a7),a4         /* get wanted */
    move.b  (a4),d6             /* get wanted[0] */
    beq     I1_3                /* wanted[0] == EOS ? */
    move.l  a4,-(sp)
    jsr     _strlen
    addq.l  #4,a7
    MOVE_   d0,d7               /* len = strlen( s ) */
I1_8:
    move.b  (a5)+,d0
    beq     I1_5                /* *s++ == EOS ? */
    cmp.b   d6,d0
    bne     I1_8                /* *s != wanted[0] */
    move.l  a5,a0
    subq.l  #1,a0               /* s is one to far */
    MOVE_   d7,-(a7)
    move.l  a4,-(a7)
    move.l  a0,-(a7)
    jsr     _strncmp             /* stnmp( s, wanted, len ) */
    lea     8+LEN(a7),a7
    tst     d0
    bne     I1_8                /* equal ? no */
    subq.l  #1,a5               /* s is one to far */
I1_3:
    move.l  a5,d0               /* return s */
    bra     I1_1
I1_5:
    moveq   #0,d0               /* return NULL */
I1_1:
    movem.l (a7)+,d6/d7/a5/a4
    rts
#endif /* TARGET == M68000 */

#endif


