/*
 *      q s t r n c p y
 *
 *  Routine to copy a QDOS string up to a maximum length.
 *  QDOS equivalent of C routine strncpy().
 *
 *  AMENDMENT HISTORY
 *  ~~~~~~~~~~~~~~~~~
 *  16 Jun 93   DJW   - First Version
 *
 *  08 Nov 93   DJW   - Changed parameter type to short
 *
 *  24 Jan 95   DJW   - Missing 'const' keyword added to function definition.
 */

#define __LIBRARY__

#include <qdos.h>
#include <string.h>

struct QLSTR * qstrncpy _LIB_F3_ (struct QLSTR *,       target, \
                                  const struct QLSTR *, source, \
                                  short,                maxlength)
{
    short  length;

    length = (source->qs_strlen > maxlength) ? maxlength : source->qs_strlen;

    (void) memmove (target->qs_str, source->qs_str, (size_t)(length + 1));
    target->qs_strlen = length;
    target->qs_str[length] = '\0';
    return (target);
}

