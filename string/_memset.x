#
/*
 * memset - set bytes
 *
 * CHARBITS should be defined only if the compiler lacks "unsigned char".
 * It should be a mask, e.g. 0377 for an 8-bit machine.
 */

#ifdef CSTRING
/*----------------------------- C Version -----------------------------*/

#include <stddef.h>
#include <string.h>

#ifndef CHARBITS
#define UNSCHAR(c)  ((unsigned char)(c))
#else
#define UNSCHAR(c)  ((c)&CHARBITS)
#endif

void *memset(s, ucharfill, size)
void *s;
int ucharfill;
size_t size;
{
    char *scan;
    size_t n;
    int uc;

    scan = (char *)s;
    uc = UNSCHAR(ucharfill);
    for (n = size; n > 0; n--)
        *scan++ = uc;

    return(s);
}
/*
 *  b z e r o
 *
 *  BSD compatible routine to set memory to zeroes.
 *  (ANSI uses memset instead)
 */

#include <memory.h>

void bzero (ptr, len)
char *ptr;
int  len;
{
    (void) memset((void *)ptr, 0, (size_t)len);
}

#else
/*------------------------- M68000 Assembler version -----------------------*/
#if (TARGET == M68000)

; AMENDMENT HISTORY
; ~~~~~~~~~~~~~~~~~
;   07 Nov 93   DJW   - Added underscore to entry point
;
;   01 Oct 94   DJW   - Added extra underscore and made names mixed case as
;                       part of implementing name hiding.
;                     - Made Johnathan Hudsons changes that use more registers
;                       to gain additonal speed on large areas, but made sure
;                       also still well optimised for smaller areas.

#include <limits.h>

#if (INT_MAX == SHRT_MAX)
#define MOVE_ move.w
#define LEN 2
#else
#define MOVE_ move.l
#define LEN 4
#endif

        .globl  __Bzero
        .globl  __MemSet
        .text

__Bzero:
        move.l  4(sp),a0            ; Target address
        moveq   #0,d2               ; Value to initialise to
#if (INT_MAX == SHRT_MAX)
        moveq   #0,d0
#endif
        MOVE_  8(sp),d0            ; Count parameter
        bra     shared

__MemSet:
        move.l  4(sp),a0            ; Target address
        move.b  8+LEN-1(sp),8+LEN-2(sp) ; \  This code replicates the
        move.w  8+LEN-2(sp),d2          ;  \ character that is to be
        swap    d2                      ;  / set up for additional speed
        move.w  8+LEN-2(sp),d2          ; /  later on in this routine
#if (INT_MAX == SHRT_MAX)
        moveq   #0,d0
#endif
        MOVE_  8+LEN(sp),d0         ; Count parameter

;   By this stage the following should be set up
;       a0  Target address
;       d0  Size of area to initialise
;       d2  Character to use (repeated 4 times)

shared:
        add.l   d0,a0               ; Set to end of area to initialise
        move.w  a0,d1               ; make copy of address in d1
        lsr.l   #1,d1               ; On even address ?
        bcc     l10                 ; ... YES, jump
        subq.l  #1,d0               ; reduce count left
        bmi     l60                 ; exit immediately if count was zero
        move.b  d2,-(a0)            ; Move across one byte


;       Try multiple register moves
l10:
        moveq   #48,d1;             ; set d1 to amount in registers
        sub.l   d1,d0               ; check this much left
        bmi     l40                 ; ... NO, then jump

        movem.l d3-d7/a2-a6,-(sp)   ; Save registers that will be corrupted
        move.l  d2,d3               ; Make copies of d2 into other registers
        move.l  d2,d4
        move.l  d2,d5
        move.l  d2,d6
        move.l  d2,d7
        move.l  d2,a1
        move.l  d2,a2
        move.l  d2,a3
        move.l  d2,a4
        move.l  d2,a5
        move.l  d2,a6
l30:    movem.l d2-d7/a1-a6,-(a0)           ; Move a whole lot of data
        sub.l   d1,d0                       ; reduce count left to move
        bpl     l30                         ; and loop while it is possible
        movem.l (sp)+,d3-d7/a2-a6           ; Restore saved registers */

l40:    add.w  d1,d0                       ; correct count back to postiive

;       Try use LONG moves while practical

        moveq   #4,d1                       ; set to try long moves
        bra     l42                         ; go to check OK

l41:    move.l  d2,-(a0)
l42:    sub.w   d1,d0
        bpl     l41

;       Finish off with BYTE moves as appropriate

        add.w   d1,d0                       ; correct count back to positive
        bra     l52                         ; go to check some left

l51:    move.b  d2,-(a0)
l52:    dbf     d0,l51

l60:    move.l  4(sp),d0
        rts

#endif /* TARGET == M68000 */

#endif

