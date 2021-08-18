/*
 *      q s t r l e n
 *
 *  Routine to find the length of a QDOS string.
 *  QDOS equivalent of C routine strlen().
 *
 *  AMENDMENT HISTORY
 *  ~~~~~~~~~~~~~~~~~
 *  15 Jun 93   DJW   - First Version
 *
 *  24 Jan 95   DJW   - Missing 'const' keyword added to function definition.
 */

#define __LIBRARY__

#include <qdos.h>
#include <string.h>

size_t qstrlen _LIB_F1_ (const struct QLSTR *, source)
{
    return ((size_t)source->qs_strlen);
}
