/*
 *      _ c o n g e t
 *
 *  Routine to ensure a console channel is available.
 *  Used in conjunction with getch(), ungetch() and putch()
 *  routines.
 *
 *  Amendment History
 *  ~~~~~~~~~~~~~~~~~
 *  20 oct 92   DJW     Changed check to merely look for _conchan
 *                      global variable set to -1L.
 */

#define __LIBRARY__

#include <qdos.h>

chanid_t _conget _LIB_F0_(void)
{
    if( _conchan == (chanid_t)-1) {
        _conchan = io_open( _conname, OLD_EXCL);
    }
    return _conchan;
}

