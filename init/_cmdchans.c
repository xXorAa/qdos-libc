/*
 *  _ c m d c h a n s
 *
 *  Internal library routine used as part of initialising the
 *  C environment for the user.
 *
 *  This routine is used to set up level 1 file descriptors
 *  for any channels resulting from re-direction on the
 *  command line.
 *
 *  Returns a channel OPEN maks, or a negative QDOS error
 *  code on error
 *
 *  It is called via a vector so that the user can suppress the
 *  inclusion of this routine if it is known that no channels
 *  will be passed via command line re-direction.
 *
 *  VERSION HISTORY
 *  ~~~~~~~~~~~~~~~
 *  12 Sep 92   DJW   - Changed code to common up handling for space 
 *                      effeciency.
 *
 *  31 Dec 93   DJW   - Made the vector to invoke this routine into a
 *                      separate file in DEFAULTS directory to allow for
 *                      easier tailoring by users to personal preferences.
 */

#define __LIBRARY__


#include <qdos.h>
#include <fcntl.h>
#include <stdlib.h>
#include <string.h>

#define ERR 1           /* Set if stdout and stderr redirected to same place */

/*
 *  This routine is actually set up as not globally visible.
 *  It is called via the default _cmdchannels vector defined later.
 */
long    _cmdchans (nc)
  long nc;
{
    char    *filename;
    int     oflag;
    int     opmode;

    /*
     *  Input channel re-directed ?
     *
     *  If it is, then open the required file
     *  and set the channel mask as open.
     *  If not, set UFB flag to stop later
     *  opens using the stdin UFB.
     */
    if (*_iname) {
        if (open( _iname, O_RDONLY ) == -1) {
            exit(ERR_NF);
        }
        nc |= 1;
    } else {
        _ufbs[0].ufbflg = UFB_OP;
    }

    /*
     *  See if Output file re-directed.
     *
     *  If it is, then we need to open the
     *  required file.  We need to allow
     *  for the fact that append mode might
     *  be specified, and also the error
     *  channel might also be redirected
     *  to the same channel.
     */
    oflag = 0;
    filename = _oname;
    if (*filename) {
        if (*filename == '>') {           /* Append mode set ? */
            opmode = O_WRONLY | O_CREAT | O_APPEND;          /* Open for appending */
            filename++;
        } else {
            opmode = O_WRONLY | O_CREAT | O_TRUNC;           /* Always overwrite file (no appending) */
        }

        if(*filename == '&') {            /* Redirect stderr as well ? */
            oflag = ERR;
            filename++;
        }
        if (open(filename, opmode) == -1) {
            exit(ERR_NF);
        }
        nc |= 2;
   } else {
        _ufbs[1].ufbflg = UFB_OP;       /* set flag to reserve UFB */
    }

    /*
     *  Is the stderr channel redirected ?
     *
     *  It can be sent either to the same
     *  channel as stdout, or to its own
     *  unique file.
     */

    filename = _ename;
    if (*filename) {
        /* Open unique error file */
        if ( *filename == '>' ) {      /* Append stderr */
            filename++;
            opmode = O_CREAT | O_WRONLY | O_APPEND;
        } else {
            opmode = O_CREAT | O_WRONLY | O_TRUNC;
        }
        if(*filename == '&') {            /* Redirect stderr as well ? */
            filename++;
        }
        if (open( filename, opmode) == -1) {
            exit (ERR_NF);
        }
        nc |= 4;                        /* Update mask as channel opened */
    }
    if (oflag) {
        /*  copy details of stdout */
        (void) memcpy (&_ufbs[2], &_ufbs[1], sizeof (struct UFB));
        _ufbs[1].ufbflg |= UFB_DP;     /* Set DUP flag */
        nc |= 4;                        /* Update mask as channel opened */
    }

    return (nc);                        /* exit returning OPEN mask */
}

