/*
 *              p u t c h
 *
 *  Lattice Comaptible routine to
 *  put a byte to a console channel.
 *
 */

#define __LIBRARY__

#include <qdos.h>

int putch  _LIB_F1_ ( char,  c)
{
    (void) io_sbyte( _conget(), (timeout_t)-1, c);
    return (int)c;
}
