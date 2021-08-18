#
/*
 * strcmp - compare string s1 to s2
 */
/* <0 for <, 0 for ==, >0 for > */

#ifdef CSTRING
/*--------------------------- C version ---------------------------*/

#include <string.h>

int strcmp(scan1, scan2)
char *scan1;
char *scan2;
{
    char c1, c2;

    do {
        c1 = *scan1++; c2 = *scan2++;
    } while (c1 && c1 == c2);

    /*
     * The following case analysis is necessary so that characters
     * which look negative collate low against normal characters but
     * high against the end-of-string NUL.
     */
    if (c1 == c2)
        return(0);
    else if (c1 == '\0')
        return(-1);
    else if (c2 == '\0')
        return(1);
/*  else */
    return(c1 - c2);
}

#else
/*------------------------- M68000 Assembler version --------------------------*/
#if ( TARGET == M68000 )

; AMENDMENT HISTORY
; ~~~~~~~~~~~~~~~~~
;   07 Nov 93   DJW   - Added underscore to entry point
;
;   28 Aug 94   DJW   - Made changes to treat string as unsigned char as
;                       required by the ANSI standard

    .globl  _strcmp

    .text

_strcmp:
    move.l  8(a7),a1        /* get s2 */
    move.l  4(a7),a0        /* get s1 */
    moveq   #0,d0
    moveq   #0,d1
I1_3:
    move.b  (a1)+,d1        /* *s2++ */
    move.b  (a0)+,d0
    beq     I1_E            /* *s1++ == EOS ? */
    cmp.b   d1,d0
    beq     I1_3            /* *s1 == *s2 ? try next */
I1_E:
    sub.l   d1,d0           /* return *s1 - *s2 */
I1_1:
    rts
#endif /* TARGET == M68000 */

#endif

