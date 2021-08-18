/*
 *      q s t r c h r
 *
 *  Routine to find a character in a QDOS string.
 *  QDOS equivalent of C routine strchr().
 *
 *  AMENDMENT HISTORY
 *  ~~~~~~~~~~~~~~~~~
 *  15 Jun 93   DJW   - First Version
 *
 *  14 Jan 95   DJW   - Missing 'const' keyword added to function definition.
 */

#define __LIBRARY__

#include <qdos.h>
#include <string.h>

char * qstrchr _LIB_F2_ (const struct QLSTR *,  source,
                         int,                   ch)
{
    return ((char *)memchr(source->qs_str, ch, (size_t)source->qs_strlen));
}

