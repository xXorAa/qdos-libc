/*
 *      q s t r i c m p
 *
 *  Routine to compare QDOS strings ignoring case.
 *  QDOS equivalent of C routine stricmp().
 *
 *  AMENDMENT HISTORY
 *  ~~~~~~~~~~~~~~~~~
 *  16 Jun 93   DJW   - First Version
 *
 *  08 Nov 93   DJW   - Changed return type to short
 */

#define __LIBRARY__

#include <qdos.h>

int qstricmp _LIB_F2_ (struct QLSTR *,  string1,
                       struct QLSTR *,  string2)
{
    return (ut_cstr (string1, string2, 1));
}

