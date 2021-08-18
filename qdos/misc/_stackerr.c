/*
 *      _ s t a c k e r r
 *
 *  This file contains the routines that are called from the
 *  C68 internal routine for stack checking.
 *
 *      _stack_error        When a failure occurs
 *      _stack_newmax       When a new maximum value is reached
 *
 * AMENDMENT HISTORY
 * ~~~~~~~~~~~~~~~~~
 *  18 Jan 94   DJW   - First version
 */

#define __LIBRARY__

#include <qdos.h>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>

long _stackmax = 0;

static char    buf[80];
static char    formatstr[]="Stack statistics:  Size=%ld, Margin=%ld, Max Used=%ld\n";

void    _stack_error (long newval)
{ 
    (void)io_sstrg (_endchanid, 1, "\n\n*** STACK CHECK ERROR **\n\n",28);
    (void) sprintf (buf,formatstr, _stack, _stackmargin, _stackmax);
    (void)io_sstrg (_endchanid, 1, buf, (short)strlen(buf));
    (void) sprintf (buf, "...now request for %ld bytes made\n", newval);
    (void)io_sstrg (_endchanid, 1, buf, (short)strlen(buf));
    (void)io_sstrg (_endchanid, 1, "\n** PROGRAM ABORTED **\n\n",24);

    exit(ERR_BO);
}

void    _stack_newmax (void)
{
    if (_endmsg != NULL) {
        (void) sprintf (buf,formatstr, _stack, _stackmargin, _stackmax);
        _endmsg = buf;
    }
    return;
}

