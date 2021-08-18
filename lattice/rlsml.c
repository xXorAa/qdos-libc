/*
 *				r l s m l
 *
 *			Routine to release memory.
 *
 *	Sanity checks are carried out the values
 *	passed as parameters to try and help avoid
 *	the program going rogue and destroying
 *	memory areas belonging to the system or to
 *	other programs.
 *
 *	When memory is released, then checks are
 *	made to see if there is now an area in the
 *	heap suitable for releasing back to QDOS.
 *
 *	Amendment History:
 *	~~~~~~~~~~~~~~~~~
 *	30 Jun 92:	EJ		(Erling Jacobsen): Code to release chunks
 *						back to QDOS rewritten totally, along with
 *						cosmetic improvements.
 *
 *	14 May 94:	EJ	  - Conditional #ifndef inserted to exclude
 *						checks, to improve speed, if wanted.
 *
 *	26 Jun 94:	EJ	  - Rewritten again, to improve speed, in a
 *						cleaner way.
 *
 *	24 Nov 94	DJW   - Added a check that address is even.
 *					  - Clear length field when releasing memory.
 *						These checks are intended to help protect
 *						against attempts to double release the same
 *						bit of memory which can have catastrophic
 *						effects on system stability.
 */

#define __LIBRARY__

#include <qdos.h>
#include <errno.h>
#include <assert.h>

typedef struct MELT *	MELTPTR;

extern	char   *_mheap; 				/* Allocated areas list */
extern	char   *_mbase; 				/* Free area list */
extern	long	_mfree; 				/* Free area size */
extern	long	_mtotal;				/* Total allocated size */

int rlsml  _LIB_F2_ (char *, cp,		/* Area to free */	 \
					long,	 lnbytes)	/* Length (in bytes) of area to free */
{
	MELTPTR chunk,prchunk;	/* chunk and previous chunk of memory */
	MELTPTR area,prarea;	/* allocations inside chunk */

	/*
	 * Sanity checks.
	 *	a) Size must be positive
	 *	b) Address must be even
	 */

	if ((lnbytes <= 0L)
	||	((unsigned long)cp & 1U))
	{
		return -1;
	}

	/* find chunk that contains our allocation */

	chunk = (MELTPTR)((long)(&_mheap)-(long)sizeof(long));

	while( chunk->mp_next )
	{
		prchunk = chunk;

		chunk = (MELTPTR)((long)chunk + (long)chunk->mp_next);

		if( (cp > (char *)chunk)
		&& (cp < ((char *)chunk + chunk->mp_size)) )
		{
			goto CHUNKFOUND;
		}

	}

	/*
	 *	If we get to here means it was not
	 *	an allocated area.
	 */
	return -1;

	CHUNKFOUND:

	/*
	 * Now we could do a similar search in the _mbase linked list of free areas
	 * to ensure that the area isn't already free'd.
	 *
	 * This is too time consuming (!!) and not in keeping with C
	 * tradition: the programmer knows what he is doing, and it is
	 * consequently his own fault if something goes wrong ...
	 * System services (like this one) are: quick and have few checks.
	 *
	 * Besides, I'd rather see a faulty program crash loudly, than
	 * seeing it survive because of a protective (and slow) library.
	 *
	 * The check above is "free", because we need to find the chunk
	 * anyway, so we can release it, if necessary.
	 *
	 * Erling Jacobsen, June 1994.
	 */

	/*
	 * Round up size to multiple of allocation unit, and then
	 * add it back into the list of memory areas currently
	 * allocated to this program that are free for use.
	 */
	lnbytes = (lnbytes + (MELTSIZE-1)) & ~(MELTSIZE-1);
	mt_lnkfr( cp, &_mbase, lnbytes);
	_mfree += lnbytes;
#if 0
	/*
	 *	We clear the size field to try and ensure
	 *	that we will fail the sanity checks if we
	 *	try and free the same area twice.
	 */
	*((long *)cp) = 0;
#endif
	/*
	 * Check the chunk we found earlier. Has it become all
	 * free ? If not, just return now.
	 */
	area = chunk + 1; /* first allocation (free or taken) inside chunk */
	if( chunk->mp_size != area->mp_size + MELTSIZE )
	{
		return 0;
	}

	/*
	 * If "chunk" is the only chunk, don't release it. The
	 * code in crt_x relies on this behaviour.
	 */
	if( (prchunk == (MELTPTR)((long)(&_mheap)-(long)sizeof(long)))
	&& (chunk->mp_next == NULL) )
	{
		return 0;
	}

	/*
	 * Now we NEED to scan the list of free areas, because
	 * we need to bypass the chunk we are about to release.
	 */
	area = (MELTPTR)((long)&_mbase - (long)sizeof(long));
	while( area->mp_next )
	{
		prarea = area;

		area = (MELTPTR)((long)area + (long)area->mp_next);

		if( area == chunk + 1 )
		{
			goto AREAFOUND;
		}

	}

	/*
	 * Some corruption may already have taken place, report it.
	 */
	return -1;

	AREAFOUND:

	/*
	 * Adjust these.
	 */
	_mtotal -= chunk->mp_size;
	_mfree -= area->mp_size;

	/*
	 * Bypass our chunk, on the list of chunks, and the list
	 * of free areas. Remember, that the mp_next pointers are
	 * RELATIVE except when they are zero, meaning End Of List.
	 */
	if( chunk->mp_next )
	{
		prchunk->mp_next = (MELTPTR)((long)chunk+(long)chunk->mp_next-(long)prchunk);
	} else {
		prchunk->mp_next = NULL;
	}
	if( area->mp_next )
	{
		prarea->mp_next = (MELTPTR)((long)area+(long)area->mp_next-(long)prarea);
	} else {
		prarea->mp_next = NULL;
	}

	mt_rechp( (char *)chunk );

	return 0;

}
