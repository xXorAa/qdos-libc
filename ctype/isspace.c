/*
 *      i s s p a c e
 *
 *  AMENDMENT HISTORY
 *  ~~~~~~~~~~~~~~~~~
 *  28 May 94   DJW   - Amended to take account of fact that offset into
 *                      _ctype array no longer needs adjusting by one.
 */
#include <ctype.h>

#undef isspace

int isspace( c )
int c;
{
    return (_ctype[c]&_S);
}
