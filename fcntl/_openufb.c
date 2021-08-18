/*
 *                  _ O p e n u f b
 *
 *  Routine that checks that attempts to find a UFBS
 *  that is not in use for opening a new file.  If it
 *  needs to, then an attempt will be made to extend
 *  the UFB table.
 *
 *  Returns fd on success, -1 on failure.
 *
 *  Used by the level 1 I/O functions.
 *
 *  CAUTION. Can cause the UFB table to move in memory.
 *
 *  AMENDMENT HISTORY
 *  ~~~~~~~~~~~~~~~~~
 *  20 Nov 95   DJW   - Added default initialisation of a 'termios'
 *                      structure within the UFB structure.
 */

#define __LIBRARY__

#include <fcntl.h>
#include <errno.h>
#include <stddef.h>
#include <string.h>
#include <termios.h>

static struct termios _condevice = {
                IGNPAR,                     /* c_iflag */
                OPOST,                      /* c_oflag */
                CLOCAL | CREAD | CS8,       /* c_cflag */
                ECHO | ECHOE | ICANON,      /* c_lflag */
                B0,                         /* c_ispeed */
                B9600,                      /* c_ospeed */
                    {
                    4,      /* cc_c[VEOF]   = CTRL-D */
                    10,     /* c_cc[VEOL]   = NL */
                    194,    /* c_cc[VERASE] = CTRL- <- */
                    0xff,   /* c_cc[VINTR]  = not used (CTRL-H) */
                    0xff,   /* c_cc[VKILL]  = not used (CTRL-U) */
                    0xff,   /* c_cc[VMIN]   = infinite */
                    188,    /* c_cc[VQUIT]  = CTRL-\ */
                    0xff,   /* c_cc[VTIME]  = infinite */
                    0xff,   /* c_cc[VSUSP]  = not used (CTRL-Z) */
                    17,     /* c_cc[VSTART] = CTRL-Q */
                    19      /* c_cc[VSTOP]  = CTRL-S */
                    }
                };


int _Openufb()
{
    struct UFB *uptr;
    int    fd;

    /*
     *  Search table to find a file handle
     *  If necessary we will try and create one.
     */
    for( fd = 0, uptr=_ufbs;  ; fd++, uptr++)
    {
        if ((uptr = _Newufb(fd)) == NULL)
        {
            errno = EMFILE;
            return -1;
        }           
        if (uptr->ufbflg == 0)
        {
            (void) memcpy (&(uptr->ufbterm), &_condevice, sizeof(struct termios) );
            return (fd);
        }
    }
}

