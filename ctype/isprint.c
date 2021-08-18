/*
 *      i s p r i n t
 *
 *  AMENDMENT HISTORY
 *  ~~~~~~~~~~~~~~~~~
 *  28 May 94   DJW   - Amended to take account of fact that offset into
 *                      _ctype array no longer needs adjusting by one.
 */
#include <ctype.h>

#undef isprint

int isprint( c )
int c;
{
    return  (_ctype[c]&(_P|_U|_L|_N|_B));
}
