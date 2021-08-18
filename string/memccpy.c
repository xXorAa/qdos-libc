/*
 *  m e m c c p y
 *
 *  copy bytes up to a certain char
 *
 * CHARBITS should be defined only if the compiler lacks "unsigned char".
 * It should be a mask, e.g. 0377 for an 8-bit machine.
 *
 * AMENDMENT HISTORY
 * ~~~~~~~~~~~~~~~~
 */

#define __LIBRARY__

#include <sys/types.h>
#include <string.h>

#ifndef CHARBITS
#define UNSCHAR(c)  ((unsigned char)(c))
#else
#define UNSCHAR(c)  ((c)&CHARBITS)
#endif

char *memccpy _LIB_F4_( char *, dst,\
                        char *, src, \
                        int,    ucharstop, \
                        size_t, size)
{
    register char *d;
    register char *s;
    register size_t n;
    register int uc;

    if (size == 0) {
        return((char *)NULL);
    }

    s = src;
    d = dst;
    uc = (int)UNSCHAR(ucharstop);
    n = size;
    while ( n-- != 0) {
        if ((int)UNSCHAR(*d++ = *s++) == uc) {
            return(d);
        }
    }

    return((char *)NULL);
}

