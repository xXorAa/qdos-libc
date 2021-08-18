/*
 *      i s p u n c t
 *
 *  AMENDMENT HISTORY
 *  ~~~~~~~~~~~~~~~~~
 *  28 May 94   DJW   - Amended to take account of fact that offset into
 *                      _ctype array no longer needs adjusting by one.
 */
#include <ctype.h>

#undef ispunct

int ispunct( c )
int c;
{
    return (_ctype[c]&_P);
}
