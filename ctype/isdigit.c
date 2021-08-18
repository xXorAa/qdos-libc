/*
 *      i s d i g i t
 *
 *  AMENDMENT HISTORY
 *  ~~~~~~~~~~~~~~~~~
 *  28 May 94   DJW   - Amended to take account of fact that offset into
 *                      _ctype array no longer needs adjusting by one.
 */
#include <ctype.h>

#undef isdigit

int isdigit( c )
int c;
{
    return (_ctype[c]&_N);
}
