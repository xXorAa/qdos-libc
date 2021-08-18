/*
 *      i s g r a p h
 *
 *  AMENDMENT HISTORY
 *  ~~~~~~~~~~~~~~~~~
 *  28 May 94   DJW   - Amended to take account of fact that offset into
 *                      _ctype array no longer needs adjusting by one.
 */
#include <ctype.h>

#undef isgraph

int isgraph( c )
int c;
{
    return (_ctype[c]&(_P|_U|_L|_N));
}
