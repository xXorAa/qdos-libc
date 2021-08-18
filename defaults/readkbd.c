/*
 *      r e a d k b d
 *
 *  This file contains the vector that is used to determine
 *  how to rad the keyboard. This vector is used by
 *  _conread().
 *
 *  The default value as specified here is io_fbyte, so
 *  _conread() ignores the mouse.
 *
 *  By including
 *
 *    int (*_readkybd)() = _readmouse
 *
 *  in a program, _conread() will call _readmouse, which
 *  also knows about the mouse, allowing moving the
 *  window.
 *
 *
 *  AMENDMENT HISTORY
 *  ~~~~~~~~~~~~~~~~~
 *  13 Apr 94  EAJ  Initial version
 */

#define __LIBRARY__

#include <qdos.h>

int (*_readkbd)(chanid_t, timeout_t, char *) = io_fbyte;

