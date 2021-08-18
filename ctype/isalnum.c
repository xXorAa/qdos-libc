/*
 *      i s a l n u m
 *
 *  AMENDMENT HISTORY
 *  ~~~~~~~~~~~~~~~~~
 *  28 May 94   DJW   - Amended to take account of fact that offset into
 *                      _ctype array no longer needs adjusting by one.
 */

#define __LIBRARY__

#include  <ctype.h>

#undef isalnum

int isalnum  _LIB_F1_(int, c)
{
    return (_ctype[c]&(_U|_L|_N));
}
