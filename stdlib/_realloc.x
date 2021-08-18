#
/*
 *			r e a l l o c
 *
 * Routine to do realloc call.
 *
 * AMENDMENT HISTORY
 * ~~~~~~~~~~~~~~~~~
 * May 1995     DJW   - Made a common source file (for tracking reasons) of
 *                      The original C implementation, and the new assembler
 *                      implementation provided by Erling Jacobsen.
 */

/* #define C_REALLOC */

/*----------------------------- C VERSION -----------------------------*/

#ifdef C_REALLOC
#define __LIBRARY__

#include <stdlib.h>
#include <string.h>

void *realloc  _LIB_F2_( void *,	ptr, \
						 size_t,	newsize)
{
	char *ret;
	size_t *oldsizeptr, copysize;

	/*
	 *	If ptr is NULL, then realloc() must act just like malloc()
	 */
	if (ptr == NULL)
		return malloc(newsize);
	/*
	 *	If newsize is 0, then realloc() must act like free()
	 */
	if (newsize == 0L) {
		free (ptr);
		return (NULL);
	}
	/*
	 *	Get a new memory area, copy as much of the contents of the
	 *	old area as will fit, and then free the old area.
	 */
	if ((ret=(char *)malloc(newsize))!= NULL) {
		oldsizeptr = (size_t *) (((long)ptr) - 4);

		if (*oldsizeptr > newsize) {
			copysize = newsize;
		} else {
			copysize = *oldsizeptr;
		}
		(void) memcpy ((void *)ret, ptr, copysize);
		free (ptr);
	}
	return ((void *)ret);
}
#else
/*-------------------------- ASSEMBLER VERSION --------------------------*/
;       realloc, by Erling Jacobsen
;
;       Attempts to reallocate "in place", without
;       moving the data.
;
;       If reducing the size of an allocation, this
;       means creating a new free area (the tail-end
;       of the original one), and linking it into the
;       memory system.
;
;       Actually, we do NOT do this, because we want
;       to use the ability of free() to release chunks
;       of memory back to QDOS, when they are free.
;
;       If expanding the allocation, first search
;       for a free area of sufficient extra size
;       which obviously must be located just after
;       the area to expand. If one exists, expand
;       into it, either by shrinking the area, or
;       eliminating it altogether, if the size fits
;       exactly.
;
;       If this is not possible, then allocate a new
;       area, move data, then free the old area.
;
;   AMENDMENT HISTORY
;   ~~~~~~~~~~~~~~~~~
;   20 May 95   DJW   - Made changes to reflect name hiding within C library

        .globl  __Realloc
        .extern __mbase
        .extern __mfree
        .extern _free
        .extern _malloc


;       arguments, rel. to a7
p       equ     4
newsize equ     8

        .text
        .even

__Realloc:

;       if newsize is zero, act like free()

        tst.l   newsize(a7)
        bne     notzero1
        jmp     _free

notzero1:

;       if p is NULL, act like malloc()

        tst.l   p(a7)
        bne     notzero2
        move.l  newsize(a7),p(a7)       ; get argument to the right place
        jmp     _malloc

notzero2:

        movea.l p(a7),a0
        subq.l  #4,a0
        move.l  (a0),d0
        subq.l  #4,d0                   ; size of allocation as user sees it

        move.l  newsize(a7),d1          ; requested size

        sub.l   d0,d1                   ; change in size
        addq.l  #7,d1
        andi.b  #$f8,d1                 ; rounded to allocation sized chunks
        tst.l   d1                      ; is area growing, shrinking or what ?

        beq     usep                    ; no change, return old area unchanged

        bgt     expand                  ; expand area, if possible, else malloc/move/free

#if 0   /* when shrinking, we prefer allocate/move/free */
        /* I kept the code here, deactivated, so others can admire it :-) */

; shrink area

        neg.l   d1                      ; shrink area by this much
        sub.l   d1,(a0)
        sub.l   d1,d0
        lea     4(a0,d0.l),a0           ; new area just after original (now smaller) area

        add.l   d1,__mfree              ; we now have some more free space

        lea     __mbase,a1              ; link free space into linked list

        movem.l a2/a3/d2/d3,-(a7)       ; preserve registers that C68 uses

        movea.w $da,a2                  ; mm.lnkfr
        jsr     (a2)

        movem.l (a7)+,a2/a3/d2/d3
        bra     usep
#else

        movem.l a2/a3/d2/d3,-(a7)       ; we need more registers here
        bra     getnew                  ; use oldfashioned way

#endif


expand: movem.l a2/a3/d2/d3,-(a7)       ; we need more registers here

        lea     __mbase,a1              ; scan free areas
        subq.l  #4,a1

        lea     4(a0,d0.l),a3           ; a3 points right after allocation

exp1:   movea.l a1,a2
        move.l  4(a1),d2
        beq     getnew
        adda.l  d2,a1
        cmpa.l  a3,a1                   ; free area just after allocation ?
        bne     exp1
        cmp.l   (a1),d1                 ; big enough ?
        bhi     getnew                  ; no
        beq     bypass                  ; just big enough

        sub.l   d1,__mfree              ; we take this much memory

        add.l   d1,(a0)                 ; expand allocation
        lea     0(a1,d1.l),a3           ; a3 points to the new, smaller free area
        add.l   d1,4(a2)                ; adjust a lot of pointers (!)
        move.l  (a1),(a3)
        sub.l   d1,(a3)
        move.l  4(a1),4(a3)
        beq     exp2
        sub.l   d1,4(a3)
exp2:   movem.l (a7)+,a2/a3/d2/d3       ; done, restore registers

usep:   move.l  p(a7),d0                ; now simply return original pointer
        rts

; we need ALL of the area, just unlink it from the list of free areas

bypass: sub.l   d1,__mfree

        add.l   d1,(a0)
        move.l  4(a1),d1
        bne     byp1
        clr.l   4(a2)
        bra     exp2
byp1:   add.l   d1,4(a2)
        bra     exp2



; we have to do things the hard way here: allocate / move / free

getnew: move.l  newsize+16(a7),-(a7)    ;get new area ( + 16 because of movem )
        jsr     _malloc
        addq.l  #4,a7
        tst.l   d0
        beq     gnerr

        movea.l d0,a1                   ; new area
        move.l  -4(a1),d2               ; length of new area

        movea.l p+16(a7),a0             ; get old area
        move.l  -4(a0),d1               ; get length of old area

        cmp.l   d1,d2                   ; get min(d1,d2)
        bcc     gn0
        move.l  d2,d1

gn0:    subq.l  #4,d1                   ; exclude header which user doesnt see
        lsr.l   #2,d1                   ; we know d1 is a multiple of 4
        move.l  d1,d2
        swap    d2
        bra     gn2
gn1:    move.l  (a0)+,(a1)+             ; so we move a longword at a time
gn2:    dbf     d1,gn1
        dbf     d2,gn1

        move.l  d0,d3                   ; save new area
        move.l  p+16(a7),-(a7)          ; free old area
        jsr     _free
        addq.l  #4,a7
        move.l  d3,d0                   ; restore new area, this is our return value

gnerr:  movem.l (a7)+,a2/a3/d2/d3       ; return it
        rts


#endif /* ! C_REALLOC */
