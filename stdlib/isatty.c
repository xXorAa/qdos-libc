/*
 *          i s a t t y
 *
 * Unix compatible routine to check if a fd is a console channel.
 */

#define __LIBRARY__

#include <qdos.h>
#include <stdlib.h>
#include <fcntl.h>

int isatty( fd )
int fd;
{
    struct UFB *p;

    if(!( p = _Chkufb( fd ))) {
        return 0;
    }

    return iscon( p->ufbfh, (timeout_t)0L );
}

