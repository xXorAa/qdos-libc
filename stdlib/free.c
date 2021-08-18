/*
 *			f r e e
 *
 *	Routine to do standard C free call.
 *
 *	Do some sanity checks before releasing memory to
 *	help protect against silly calls to free.
 */

#define __LIBRARY__

#include <qdos.h>
#include <stdlib.h>
#include <assert.h>

void free _LIB_F1_(void *, ptr)
{
	long	*baseptr;

	assert (stackcheck());
	if (ptr == NULL)							/* Has a NULL pointer been passed ? */
	{
		return;
	}
	baseptr = (long *)(((long)ptr) - 4);		/* Reset to true base */

	if ( (*baseptr == 0L)						/* Is element size set ? */
	||	 ((unsigned long)baseptr & (unsigned long)(MELTSIZE-1)) ) /* Is it on an allocation boundary ? */
	{
		return;
	}

	(void) rlsml( (char *)baseptr, *baseptr);	/* OK we give in and release memory */
	return;
}
