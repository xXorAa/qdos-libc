/*
 *      b e e p
 *
 * Quick routine to do a beep.
 *
 *  08 Nov 93   DJW   - Changed parameter types to short
 */

#define __LIBRARY__

#include <qdos.h>

void beep   _LIB_F2_( unsigned short,dur, unsigned char,pitch)
{
    do_sound( dur, pitch, 0, 0, 0, 0, 0, 0);
}

