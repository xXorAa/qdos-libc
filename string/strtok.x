#
/*
 * Get next token from string s (NULL on 2nd, 3rd, etc. calls),
 * where tokens are nonempty strings separated by runs of
 * chars from delim.  Writes NULs into s to end tokens.  delim need not
 * remain constant from call to call.
 *
 *  If CSTRING is not defined, then assembler version is used
 *   N.B. The assembler is not portable to other processor types,
 */

#ifdef CSTRING
/*------------------------------- C Version -------------------------------*/

#include <string.h>

static char *scanpoint = NULL;

/* returns NULL if no token left */

char *strtok(s, delim)
char *s;
char *delim;
{
    char *scan;
    char *tok;
    char *dscan;

    if (s == NULL && scanpoint == NULL)
        return(NULL);
    if (s != NULL)
        scan = s;
    else
        scan = scanpoint;

    /*
     * Scan leading delimiters.
     */
    for (; *scan != '\0'; scan++) {
        for (dscan = delim; *dscan != '\0'; dscan++)
            if (*scan == *dscan)
                break;
        if (*dscan == '\0')
            break;
    }
    if (*scan == '\0') {
        scanpoint = NULL;
        return(NULL);
    }

    tok = scan;

    /*
     * Scan token.
     */
    for (; *scan != '\0'; scan++) {
        for (dscan = delim; *dscan != '\0';)	/* ++ moved down. */
            if (*scan == *dscan++) {
                scanpoint = scan+1;
                *scan = '\0';
                return(tok);
            }
    }

    /*
     * Reached end of string.
     */
    scanpoint = NULL;
    return(tok);
}

#else
/*-------------------------- M68000 Assembler version --------------------*/
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

    .data
scanpoint:
    dc.l    0

    .globl  _strtok

    .text
_strtok:
    movem.l a5/a4,-(a7)     /* save registers */
    move.l  8+4(a7),a4      /* get s */
    move.l  8+8(a7),a5      /* get delim */
    move.l  a4,d0
    bne     I1_8            /* s != EOS ? */
    tst.l   scanpoint
    beq     I1_7            /* scanpoint == EOS ? */
    move.l  scanpoint,a4   /* s = scanpoint */
I1_8:
    move.l  a5,a1           /* store delim */
I1_C:
    move.b  (a4)+,d0        /* *s++ */
    beq     I1_E            /* EOS of s ? */
    move.l  a1,a5           /* restore delim */
I1_10:
    move.b  (a5)+,d1        /* *delim++ */
    beq     I1_18           /* EOS of delim ? */
    cmp.b   d1,d0
    bne     I1_10           /* *s != *delim ? */
    bra     I1_C
I1_E:
    clr.l   scanpoint      /* scanpoint = NULL */
I1_7:
    moveq.l #0,d0           /* return NULL */
    bra     I1_1
I1_18:
    subq.l  #1,a4           /* adjust s ( --s ) */
    move.l  a4,a0           /* token = s */
I1_1D:
    move.b  (a4)+,d0        /* *s++ */
    beq     I1_1A           /* EOS of s ? */
    move.l  a1,a5           /* restore delim */
I1_21:
    move.b  (a5)+,d1        /* *delim++ */
    beq     I1_1D           /* EOS of delim ? */
    cmp.b   d1,d0
    bne     I1_21           /* *s != *delim ? */
    move.l  a4,scanpoint   /* scanpoint = s */
    clr.b   -1(a4)          /* *(s - 1) = EOS */
    bra     I1_3
I1_1A:
    clr.l   scanpoint
I1_3:
    move.l  a0,d0           /* return token */
I1_1:
    movem.l (sp)+,a5/a4     /* restore registers */
    rts
#endif /* TARGET == M68000 */
#endif


