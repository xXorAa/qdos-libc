#
/*
 *          s t r f n d
 *
 *
 *  Find position of string1 inside string2, case dependant
 *  (for case dependant version use strfind() which is a Unix
 *  compatible routine defined in libgen.h).
 *
 *  C Syntax:
 *          int     strfnd (const char * string1,
 *                          const char * string2)
 *
 *  Returns:
 *      -1      no match
 *      other   position of string1 in string2
 *
 * AMENDMENT HISTORY
 * ~~~~~~~~~~~~~~~~~
 *  03 Oct 93   DJW   - Changed to use pointer arithmetic in place of array
 *                      arithmetic for improved performance/size.
 *
 *  21 Jun 94   DJW   - Casts added to correctly handle characters with
 *                      internal values above 127.
 *
 *  25 Jan 95   DJW   - Added 'const' keywords to parameter definitions
 *
 *  20 Dec 96   DJW   - Removed option for case dependant matching - that
 *                      is now handled by the Unix compatible strfind() routine.
 *  20 may 97   DJW   - Switched to using assembler version by default
 *                      (based on code provided by Phil Borman).
 *                      Added option to generate test program if TESTING defined.
 */

#ifdef TESTING
/*---------------------------- TEST PROGRAM ----------------------------*/
#include <stdio.h>
#include <string.h>

/*
 *  List of inputs and expected result
 */
struct TESTDATA {
        char *  string1;
        char *  string2;
        int     result;
        } *pTestData, TestData[] = {
                    {"abc", "ABCdef",  0},
                    {"abc", "defabcd", 3},
                    {"ABC", "defabdc", -1},
                    {"ABC", "defaBc", 3},
                    {"abc", "ab", -1},
                    {"", "ABC", 0},
                    {"", "",  0},
                    {"abc", "", -1},
                    {"ab", NULL, -1},
                    {NULL, "abc", -1},
                    {NULL, NULL, -99}
                    };

int main (argc, argv)
        int argc;
        char ** argv;
{
    printf ("Test of strfnd() function\n");
    printf ("~~~~~~~~~~~~~~~~~~~~~~~~~\n");
    printf ("%-15s %-15s %-10s %-10s\n", "string1", "string2", "return", "result");
    printf ("%-15s %-15s %-10s %-10s\n", "-------", "-------", "------", "------");

    for (pTestData = TestData ; pTestData->result != -99 ; pTestData++)
    {
        int result;

        printf ("%-15s %-15s", pTestData->string1, pTestData->string2);
        result = strfnd (pTestData->string1, pTestData->string2);
        printf ("%5d      %-10s\n", result, result == pTestData->result ? "OK" : "ERROR");
    }
    return 0;
}

#else /* TESTING */

/*
 *  If CSTRING is not defined, then assembler version is used.
 *  N.B.  Not portable to other processor types or other pointer sizes
 */

#ifdef CSTRING
/*-------------------------  C version --------------------------------*/
#define __LIBRARY__

#include <string.h>
#include <ctype.h>

int strfnd _LIB_F3_(const char *,   s1, \
                    const char *,   s2)
{
    const char    *p;
    const char    *p1;
    const char    *p2;

    for( p = s2; *p; p++) 
    {
        for (p1=s1, p2=p ; *p1 && *p2 ; p1++, p2++) 
        {
            if (tolower((unsigned char)*p1) != tolower((unsigned char)*p2)) 
            {
                break;
            }
        }
        /*
         *  If end of string1 reached - we have a match
         */
        if( *p1 == '\0') 
        {
            return (int)(p - s2);
        }
    }           
    return -1;
}

#else
/*-------------------------- M68000 Assembler version -----------------------*/
#if (TARGET == M68000)

; AMENDMENT HISTORY
; ~~~~~~~~~~~~~~~~~
;   20 May 97   DJW   - First version based on Phil Bormans code, but using
;                       much faster Exclusive OR method for comparisons.

.globl _strfnd

SAVEREG = 5*4+4

_strfnd:
        movem.l a0/a1/d1/d2/d3,-(sp)
        move.l  SAVEREG+0(a7),d2    /* get string1 */
        beq     badx                /* NULL parameter */
        move.l  SAVEREG+4(a7),d3    /* and string2 */
        beq     badx                /* NULL parameter */
        subq.l  #1,d3               /* Adjust for loop start */
restart:
        move.l  d2,a0               /* get base of search string */
        addq.l  #1,d3               /* Update start point */
        move.l  d3,a1               /* ... and set as where we are looking */
loop:
        move.b  (a0)+,d0            /* End of S1 ? */
        beq     end_s1              /* ... yes - we are finished */
        move.b  (a1)+,d1            /* End of S2 ? */
        beq     badx                /* ... YES, nothing further to do */
        eor.b   d1,d0               /* Any identical bits are cleared */
        andi.b  #223,d0             /* ... and ignore bit 6 */
        beq     loop                /* If equal, then loop for next */
        bra     restart             /* ... Else move up target string */

end_s1:
        move.l  d3,d0               /* get found start in target */
        sub.l   SAVEREG+4(a7),d0    /* subtract original start point */
bye:
        movem.l (sp)+,a0/a1/d1/d2/d3 /* restore registers */
        rts

badx:
        moveq   #-1,d0              /* set error exit */
        bra     bye

#endif /* TARGET == M68000 */

#endif /* ! CSTRING */

#endif /* ! TESTING */
