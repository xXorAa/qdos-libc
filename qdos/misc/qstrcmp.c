/*
 *      q s t r c m p
 *
 *  Routine to compare QDOS strings.
 *  QDOS equivalent of C routine strcmp().
 *
 *  AMENDMENT HISTORY
 *  ~~~~~~~~~~~~~~~~~
 *  16 Jun 93   DJW   - First Version
 *
 *  14 Jan 95   DJW   - Missing 'const' keyword added to function definition.
 */

#define __LIBRARY__

#include <qdos.h>

int qstrcmp _LIB_F2_ ( const struct QLSTR *,    string1,    \
                       const struct QLSTR *,    string2)
{
    return (ut_cstr (string1, string2, 0));
}

