/*
 *		q s t r c a t
 *
 *	Routine to concatenate one QDOS string to another.
 *	QDOS equivalent of C routine strcat().
 *
 *	AMENDMENT HISTORY
 *	~~~~~~~~~~~~~~~~~
 *	15 Jun 93	DJW   - First Version
 */

#define __LIBRARY__

#include <qdos.h>
#include <string.h>

struct QLSTR * qstrcat _LIB_F2_ (struct QLSTR *,	   target, \
								 const struct QLSTR *, source)
{
	(void) memmove (&target->qs_str[target->qs_strlen], 
					&source->qs_str[0], source->qs_strlen);
	target->qs_strlen += source->qs_strlen;
	target->qs_str[target->qs_strlen] = '\0';
	return (target);
}
