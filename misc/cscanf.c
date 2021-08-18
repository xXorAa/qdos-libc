#include <qdos.h>
#include <stdio.h>

#define BUF_SIZE 256
struct constuff {
    chanid_t chid;
    char buff[BUF_SIZE];
    unsigned char *p;
    int len;
};

/********************************************************
 * Local routine to get the next character from the     *
 * buffer or console.                                   *
 ********************************************************/

static int congetc( sp )
struct constuff *sp;
{
    /* Get a character from the buffer or another line from the file */	
    if( sp->len == 0 || (sp->p - sp->buff >= sp->len)) {
        if ((sp->len = io_fline( (chanid_t)sp->chid, (timeout_t)-1,sp->buff,
                (long)sizeof(sp->buff) )) == 0 )
            return EOF;
        sp->p = sp->buff;
    }

    return (int)*sp->p++;
}

/********************************************************
 * Routine to push a character back.                    *
 ********************************************************/

static int conungetc( c, sp )
int c;
struct constuff *sp;
{
    if(c == EOF)
        c = '\0';
    return (int)(*--sp->p = c);
}

/********************************************************
 * Console scanf routine.                               *
 ********************************************************/

int cscanf( fmt, args)
char *fmt;
char *args;
{
    extern chanid_t _conget();
    struct constuff p;

    p.chid = _conget();
    p.len = 0;
    return (_scanf(&p, congetc, conungetc, fmt, &args));
}

