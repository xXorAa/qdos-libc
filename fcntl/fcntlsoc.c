/*
 *  f c n t l s o c
 *
 *  Dummy vector for socket fcntl() calls when socket library not used
 *
 *  AMENDMENT HISTORY
 *  ~~~~~~~~~~~~~~~~~
 *  11 Aug 98   DJW   - First version
 */

#define __LIBRARY__

#include <stddef.h>

int  fcntl_socket  _LIB_F3_(int,  fd, \
                            int,  action, \
                            int,  flags)
{
    (void)fd;
    (void)action;
    (void)flags;

    return -1;
}

