#include <qdos.h>
#include <stdio.h>

/********************************************************
 * Routine to do printf's to a console channel.         *
 ********************************************************/

static int outrtn( c, chid )
unsigned char c;
chanid_t chid;
{
    io_sbyte( chid, (timeout_t)-1, (char)c);
    return ((int) c);
}

int cprintf( fmt, args)
char *fmt;
char *args;
{
    extern chanid_t _conget();

    return (_printf( (chanid_t)_conget(), &outrtn, fmt, &args));
}
