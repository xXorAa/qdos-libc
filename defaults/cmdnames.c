/*
 *      c m d n a m e s _ c
 *
 *  Defines names for command channels
 *
 *  AMENDMENT HISTORY
 *  ~~~~~~~~~~~~~~~~~
 *  30 Aug 98   DJW   - Changed to take the buffer size to be used from
 *                      the limits.h file rather than hard coding the size.
 *                      (Problem reported by David Gilham).
 */

#include <limits.h>

char    _iname[MAXNAMELEN];
char    _oname[MAXNAMELEN];
char    _ename[MAXNAMELEN];
