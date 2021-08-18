#
/*
 * memcpy - copy bytes
 *
 *  If CSTRING is not defined, then assembler version is used
 *  N.B. The assembler is not portable to other processor types,
 */

#ifdef CSTRING
/*---------------------------- C Version ----------------------------- */

#include <stddef.h>
#include <string.h>

void *memcpy(dst, src, size)
char *dst;
char *src;
size_t size;
{
    char *d;
    char *s;
    size_t n;

    if (size == 0)
        return((void *)dst);

    s = src;
    d = dst;
    if (s <= d && s + (size-1) >= d) {
        /* Overlap, must copy right-to-left. */
        s += size-1;
        d += size-1;
        for (n = size; n > 0; n--)
            *d-- = *s--;
    } else
        for (n = size; n > 0; n--)
            *d++ = *s++;

    return((void *)dst);
}
/* 
 * memmove
 *
 * Moves a block of memory (safely).
 * Calls memcpy(), so memcpy() had better be safe.
 * Henry Spencer's routine is fine.
 */

void *memmove(s1, s2, n)
void * s1, *s2;
size_t n;
{
  return memcpy(s1, s2, n);
}

/*
 *  b c o p y
 *
 *  BSD compatible routine to copy memory.
 *  (ANSI uses memcpy instead)
 */

#include <memory.h>

char * bcopy (src, dest, len)
char *src;
char *dest;
int  len;
{
    return (char *)memcpy((void *)dest,(void *)src,(size_t)len);
}

#else
/*--------------------------- M68000 Assembler version ---------------------*/
#if (TARGET == M68000)

; AMENDMENT HISTORY
; ~~~~~~~~~~~~~~~~~
;   07 Nov 93   DJW   - Added underscore to entry point
;
;   01 Oct 94   DJW   - Added extra underscores for name hiding purposes,
;                       and changed names to mix case at same time
;                     - Made changes to use Johnathan Hudsons version that 
;                       uses additional registers to get extra speed.

#include <limits.h>

#if (INT_MAX == SHRT_MAX)
#define MOVE_ move.w
#else
#define MOVE_ move.l
#endif

        .globl  __Bcopy
        .globl  __MovMem
        .globl  __MemCpy
        .globl  __MemMove
        .text
*
* _ALL_ these routines are safe with overlapping memory
*
__Bcopy:
__MovMem:
        move.l  4(sp),a0                ; Source
        move.l  8(sp),a1                ; Target
        bra     memgo

__MemCpy:
__MemMove:
        move.l  4(sp),a1                ; Target
        move.l  8(sp),a0                ; Source

memgo:
#if (INT_MAX == SHRT_MAX)
        moveq   #0,d0                   ; ensure top bits clear if 16 bit int
#endif
        MOVE_   12(sp),d0               ; size
        move.l  a1,-(sp)                ; save target as return value

        cmp.l   a0,a1                   ; addresses equal ?
        beq     finish                  ; ... YES, exit immediatly
        bls     x0                      ; ... JUMP if source < target

;       We are going to copy backwards

        adda.l  d0,a0               ; set to end of source
        adda.l  d0,a1               ; set to end of target
        move.w  a0,d1
        move.w  a1,d2
        or.w    d1,d2
        andi.w  #1,d2               ; addresses both aligned ?
        bne     b06                 ; ... NO, we better do byte moves

        cmp.l   #259,d0             ; Is it worth doing large moves ?
        bcs     l08                 ; NO, then jump

;       Do large moves using multiple registers

        move.l  d0,d1               ; copy count
        divu    #44,d1              ; divide by size of register move
        bvs     l08                 ; too large - revert to simpler methods
        movem.l d3-d7/a2-a6,-(sp)   ; save potential register variables
        moveq   #44,d0              ; set count we will move per go
        bra     b00                 ; ,,, and join loop
b01:    sub.l   d0,a0    
        movem.l (a0),d2-d7/a2-a6    
        movem.l d2-d7/a2-a6,-(a1)  
b00:    dbf     d1,b01              ; loop until count expired
        swap    d1                  ; get remainder
        move.w  d1,d0               ; set as count left to do
        movem.l (sp)+,d3-d7/a2-a6   ; restore saved registers

;       Now try 8 byte moves

l08:    move.w  d0,d1    
        lsr.l   #3,d0               ; Divide by 8
        bra     b03
b02:    move.l  -(a0),-(a1)         
        move.l  -(a0),-(a1)        
b03:    dbf     d0,b02
#if (INT_MAX != SHRT_MAX)
        sub.l   #$10000,d0
        bcc     b02
#endif
        move.b  d1,d0
        and.l   #7,d0
        bne     b06
        bra     finish

;       Now try 1 byte moves
;       N.B.  We may get here with large counts for unaligned operands

b05:    move.b  -(a0),-(a1)        
b06:    dbf     d0,b05          ; loop until finished
#if (INT_MAX != SHRT_MAX)
        sub.l   #$10000,d0      ; ... then try for next 64Kb
        bcc     b05
#endif
finish:
        move.l  (sp)+,d0            ; set target as return value
        rts


;   We need to copy forwards if we get to here

x0:     move.w  a0,d1
        move.w  a1,d2
        or.w    d1,d2
        andi.w  #1,d2               ; addresses both aligned ?
        bne     b0c                 ; ... NO, we better do byte moves
        cmp.l   #259,d0             ; worth doing large register moves ?
        bcs     x08                 ; ... NO, go for 8 byte moves

        move.l  d0,d1
        divu    #44,d1
        bvs     x08                 ; overflow - revert to simpler method
        movem.l d3-d7/a2-a6,-(sp)   ; save registers that will be used
        moveq   #44,d0
        bra     b07
b08:    movem.l (a0)+,d2-d7/a2-a6   ; Move data into registers
        movem.l d2-d7/a2-a6,(a1)    ; Now move to target
        add.l   d0,a1
b07:    dbf     d1,b08              ; loop until expired
        swap    d1                  ; get remainder
        move.w  d1,d0               ; set count
        movem.l (sp)+,d3-d7/a2-a6   ; restore saved registers

;    Do 8 byte moves

x08:    move.w  d0,d1
        lsr.l   #3,d0               ; Divide by 8
        bra     b09                 ; join loop
b0a:    move.l  (a0)+,(a1)+         
        move.l  (a0)+,(a1)+         
b09:    dbf     d0,b0a
#if  (INT_MAX != SHRT_MAX)
        sub.l   #$10000,d0
        bcc     b0a
#endif
        move.b  d1,d0               ; restore count
        and.l   #7,d0               ; isolate last few bits
        beq     finish              ; ... fast exit if expired
        bra     b0c

;   Use 1 byte moves

b0b:    move.b  (a0)+,(a1)+
b0c:    dbf     d0,b0b
#if (INT_MAX != SHRT_MAX)
        sub.l   #$10000,d0
        bcc     b0b                 ; go for next 64Kb
#endif
        bra     finish

#endif /* TARGET == M68000 */

#endif

