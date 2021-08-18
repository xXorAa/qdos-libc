#
/*
 *		q s o r t _ c
 *
 *	The qsort function sorts an array of n objects, the initial
 *	element of which is pointed to by 'base'.  The size of each
 *	object is specified by 'size'.
 *
 *	The contents of this array are sorted into ascending order
 *	according to a user supplied comparison funcion '_cmpfunction'
 *	which ius called with two arguments that point to the objects
 *	being compared.  The function must return an integer less than,
 *	equal to, or greater than zero if the first argument is 
 *	considered to be repectively less than, equal to, or greater
 *	than the second.
 *
 *	IF two elements conmpare as equal then their order in the
 *	array is unspecified.
 *
 *	The C version of this routine is written to use a QUICKSORT approach.
 *	The assembler version of this routine is written to use a HEAPSORT approach.
 *
 *	AMENDMENT HISTORY
 *	~~~~~~~~~~~~~~~~~
 *	02 Jan 95	DJW   - Added missing 'const' qualifiers to function declaration
 *
 *	12 Jan 95	DJW   - Merged in the assembler version supplied by Erling
 *						Jacobsen, and made this the default unless CVERSION
 *						is defined
 */


#ifdef CVERSION
/*---------------------------------------------------------------------*/
#include <stdlib.h>
#include <string.h>

	/* macros */
#define MAX_BUF 256 	/* chunk to copy on swap */

void qsort	(base, n, size, cmpfunction)
  void	  *base;
  size_t  n;
  size_t  size;
  int	  (*cmpfunction)(const void *, const void *);
{
	/* sort (char base[size])[nelem] using quicksort */
	while (1 < n) {
		/* worth sorting */
		size_t i = 0;
		size_t j = n - 1;
		char *qi = base;
		char *qj = qi + size * j;
		char *qp = qj;

		while (i < j) {
			/* partition about pivot */
			while (i < j && (*cmpfunction)(qi, qp) <= 0) {
				++i;
				qi += size;
			}
			while (i < j && (*cmpfunction)(qp, qj) <= 0) {
				--j;
				qj -= size;
			}
			if (i < j) {
				/* swap elements i and j */
				char buf[MAX_BUF];
				char *q1 = qi;
				char *q2 = qj;
				size_t m, ms;
				for (m = ms = size; 0 != ms;  ms -= m, q1 += m, q2 -= m)  {
					/* swap as many as possible */
					m = ms < sizeof (buf) ? ms : sizeof (buf);
					(void) memcpy(buf, q1, m);
					(void) memcpy(q1, q2, m);
					(void) memcpy(q2, buf, m);
				}
				++i;
				qi += size;
#ifdef GENERIC
				/*	Including the following line causes problems!!! */
				--j;
				qj -= size;
#endif
			}
		}
		if (qi != qp)	{
			/* swap elements i and pivot */
			char buf[MAX_BUF];
			char *q1 = qi;
			char *q2 = qp;
			size_t m, ms;

			for (m = ms = size; 0 != ms; ms -= m, q1 += m, q2 -= m)  {
				/* swap as many as possible */
				m = ms < sizeof (buf) ? ms : sizeof (buf);
				(void) memcpy(buf, q1, m);
				(void) memcpy(q1, q2, m);
				(void) memcpy(q2, buf, m);
			}
		}
		j = n - i;
		if (j < i)	{
			/* recurse on smaller partition */
			if (1 < j)
				qsort(qi, j, size, cmpfunction);
			n = i;
		}  else  {
			/* lower partition is smaller */
			if (1 < i)
				qsort(base, i, size, cmpfunction);
			base = (void *)qi;
			n = j;
		}
	}
}

#else
/*-------------------------- Assembler version --------------------*/
#if (TARGET == M68000)
;
;	this is a heapsort algorithm, disguised as qsort().
;
;	the algorithm takes time proportional to n * log n,
;	quicksort typically also takes time proportional to n * log n,
;	and may even be a bit faster than heapsort.
;
;	however, quicksort takes time proportional to n * n when
;	the data is already (nearly) sorted, which is very nasty.
;
;	heapsort does not exhibit such nasty behaviour, as it always
;	sticks to n * log n.
;
;	the fact that heapsort takes slightly longer than quicksort
;	is disguised by the fact that this implementation is written
;	in machinecode directly, not compiled from C.
;
;	as this version of qsort() is at least as fast as the previous one
;	and better behaved, I suggest this one replaces it.
;
;	Erling Jacobsen, Nov. 1994
;
;
;	AMENDMENT HISTORY
;	=================
;
;	26 Nov 94	EAJ Adapted to the name hiding of C68 4.14
;

	.text
	.even
	.globl	__Qsort

doheap:
	movem.l d5/d7/a6,-(a7)

l1: move.l	d7,d5
	add.l	d5,d5
	cmp.l	d5,d6
	bcs dhq
	beq l3
l2: lea 0(a3,d5.l),a0
	pea 0(a0,d3.l)
	move.l	a0,-(a7)
	jsr (a4)
	addq.l	#8,a7
	tst.l	d0
	bgt l3
	add.l	d3,d5

l3: lea 0(a3,d7.l),a5
	lea 0(a3,d5.l),a6
	move.l	a6,-(a7)
	move.l	a5,-(a7)
	jsr (a4)
	addq.l	#8,a7
	tst.l	d0
	bge dhq
	move.l	d3,d0
	move.l	d0,d1
	swap	d1
	bra l5
l4: move.b	(a5),d2
	move.b	(a6),(a5)+
	move.b	d2,(a6)+
l5: dbf d0,l4
	dbf d1,l4
	move.l	d5,d7
	bra l1

dhq:	movem.l (a7)+,d5/d7/a6
	rts



__Qsort:
	link a6,#0
	movem.l d2/d3/d4/d5/d6/d7/a3/a4/a5,-(a7)

	movea.l 8(a6),a3	;base
	move.l 16(a6),d3	;size
	suba.l d3,a3		;base, assuming pascal style indexing !

	movea.l 20(a6),a4	;compare function

	move.l	12(a6),d4	;n

	move.l	d4,d0
	move.l	d0,d1		;n

	move.l	d3,d6
	mulu	d0,d6
	swap	d0
	swap	d6
	mulu	d3,d0
	add.w	d0,d6
	move.l	d3,d2
	swap	d2
	mulu	d2,d1
	add.w	d1,d6
	swap	d6		; n * size

	move.l	d4,d0
	lsr.l	#1,d0
	move.l	d0,d1		;n / 2

	move.l	d3,d5
	mulu	d0,d5
	swap	d0
	swap	d5
	mulu	d3,d0
	add.w	d0,d5
	move.l	d3,d2
	swap	d2
	mulu	d2,d1
	add.w	d1,d5
	swap	d5		;size * (n div 2)

l10:	beq l12
l11:	move.l	d5,d7
	bsr doheap
	sub.l	d3,d5
	bne l11
l12:

	move.l	d6,d5
	move.l	d3,d7

l13:	cmp.l	d3,d5
	ble l16

	lea 0(a3,d3.l),a0
	lea 0(a3,d5.l),a1
	move.l	d3,d0
	move.l	d0,d1
	swap	d1
	bra l15
l14:	move.b	(a0),d2
	move.b	(a1),(a0)+
	move.b	d2,(a1)+
l15:	dbf d0,l14
	dbf d1,l14

	move.l	d5,d6
	sub.l	d3,d6
	bsr doheap

	sub.l	d3,d5
	bra l13
l16:

	movem.l (a7)+,d2/d3/d4/d5/d6/d7/a3/a4/a5
	unlk	a6
	rts

#endif /* TARGET == M68000 */

#endif	/* ! CVERSION */
