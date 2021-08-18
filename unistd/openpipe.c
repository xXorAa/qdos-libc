/*
 *                  p i p e
 *
 *  Unix compatible routine to allow input and output pipes
 *  to be constructed, connected to each other.
 */

#define __LIBRARY__

#include <unistd.h>
#include <qdos.h>
#include <errno.h>
#include <fcntl.h>
#include <stdio.h>
#include <string.h>

int pipe  _LIB_F1_( int,    fdp[2])     /* Two file descriptors,
                                            fdp[0] = I/P pipe, 
                                            fdp[1] = O/P pipe */
{
    int     psize;
    char    *bp, plen[20], pipeout[32];

    /*
     *  Calculate the output pipe size as a string.
     */
    bp = &plen[sizeof(plen)];
    *--bp = '\0'; /* Set end of text buffer as EOS */
    for (psize = _pipesize ; psize ; ) {
        *--bp = (char)(( psize % 10) + '0'); /* Get ASCI for lowest digit of psize */
        psize /= 10; /* Divide by 10 to get next digit */
    }

    /*
     *  The output pipe name is built by taking the input
     *  pipe name and adding the length to it.  This is
     *  opened first as fdp[1].
     *
     *  The input pipe is opened using the channel returned
     *  from opening the output pipe as the 'mode' as fdp[0].
     */
    (void) strcpy (pipeout, "pipe_");
    (void) strcat (pipeout, bp);
    if(( fdp[1] = open( pipeout, O_WRONLY)) == -1)
        return (-1);

    if ((fdp[0] = open( "pipe", getchid( fdp[1] ))) == -1) {
        /* Save error numbers before closing output pipe */
        int     nerrno  = errno;
        int     _noserr = _oserr;
        (void) close( fdp[1] );
        errno = nerrno;
        _oserr = _noserr;
        return -1;
    }

    return 0;   /* Successfull pipe set opened */
}

