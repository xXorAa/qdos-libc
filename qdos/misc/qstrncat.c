/*
 *      q s t r n c a t
 *
 *  Routine to concatenate one QDOS string
 *  up to a maximumm length to another.
 *  QDOS equivalent of C routine strncat().
 *
 *  AMENDMENT HISTORY
 *  ~~~~~~~~~~~~~~~~~
 *  15 Jun 93   DJW   - First Version
 *
 *  08 Nov 93   DJW   - Changed return type to short
 *
 *  24 Jan 95   DJW   - Missing 'const' keyword added to function definition.
 */

#define __LIBRARY__

#include <qdos.h>
#include <string.h>

struct QLSTR * qstrncat _LIB_F3_(struct QLSTR *,        target, \
                                  const struct QLSTR *, source, \
                                  short,                maxlength)
{
    short length;

    length = (source->qs_strlen > maxlength) ? maxlength : source->qs_strlen;

    (void) memmove (&target->qs_str[target->qs_strlen], 
                    &source->qs_str[0], (size_t)length);
    target->qs_strlen += length;
    target->qs_str[length] = '\0';
    return (target);
}

