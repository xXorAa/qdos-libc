/*
 *		q s t r c p y
 *
 *	Routine to copy a QDOS string.
 *	QDOS equivalent of C routine strcpy().
 *
 *	AMENDMENT HISTORY
 *	~~~~~~~~~~~~~~~~~
 *	16 Jun 93	DJW   - First Version
 *
 *	24 Jan 95	DJW   - Missing 'const' keyword added to function definition.
 */

#define __LIBRARY__

#include <qdos.h>
#include <string.h>

struct QLSTR * qstrcpy _LIB_F2_ (struct QLSTR *,	   target, \
								 const struct QLSTR *, source)
{
	(void) memmove (&target, &source, (size_t)source->qs_strlen + 3);
	target->qs_str[target->qs_strlen] = '\0';
	return (target);
}
