/*
 *                  _ e x i t _ c
 *
 *  Routine to terminate a program - using QDOS
 *  force remove call.
 *
 *  If we are running under the QDOS Pointer Environment, and the
 *  option has not been suppressed, we output a message and wait for
 *  a keypress.   This stops the Pointer Environment "tidying" up the
 *  screen by restoring the windows underlying contents before the user
 *  has a chance to read any messages from the program.
 *
 *  AMENDEMENT HISTORY
 *  ~~~~~~~~~~~~~~~~~~
 *  07 MAY 93   DJW   - Removed the loop on the mt_frjob() call as this was
 *                      unnecessary - this call cannot fail!
 *
 *  13 Apr 94   EAJ   - Calls io_fbyte through the vector _readkybd. See
 *                      _conread and _readmouse for explanation.
 *
 *  14 Oct 94   DJW   - Moved the '_endchanid' and '_f_onexit' variables to
 *                      the startup module as part dding RLL support.
 *                    - Other changes to allow a RLL version of this routine
 *                      to be generated.
 *
 *  28 Sep 95   DJW   - The exit message now uses the global variable
 *                      '_endtimeout' to make this a programmer configurable
 *                      item.
 *                    - Pressing ESC when on the timeout message now does a
 *                      "wait forever" whatever the timeout is set to.
 *                      (idea copied from InfoZip port by Jonathan Hudson).
 */

#define __LIBRARY__

#include <qdos.h>
#include <string.h>
#include <unistd.h>

#ifdef RLL_LIBS
#define _F_ONEXIT   vars->_f_onexit
#define _ENDCHANID  vars->_endchanid

void _RLL_exit (struct _StdVars * vars,
                 char * dummy,
                 int code)

#else

#define _F_ONEXIT   _f_onexit
#define _ENDCHANID  _endchanid

void _exit( int  code )
#endif
{
    /*
     *  Function to call on exit - before quitting
     */
    if( _F_ONEXIT != NULL )
        code = (*_F_ONEXIT)( code );
    /*
     *  Output a message and wait for kepress if required
     */
    if ((_endchanid != 0L) && (_endmsg != (char *)NULL)) {
        char c;

        (void) io_sstrg(_ENDCHANID, _endtimeout, _endmsg, (short)strlen(_endmsg));
        (void) sd_cure( _ENDCHANID, (timeout_t)1L); /* Ensure a cursor is enabled */

        (void) (*_readkbd)( _ENDCHANID, _endtimeout, &c);
        if (c == 27)
            (void) (*_readkbd)( _ENDCHANID, (timeout_t)-1, &c);
        (void) sd_curs( _ENDCHANID, (timeout_t)1L); /* Ensure a cursor is suppressed */
    }
    /*
     *  Finally, we kill ourselves with the appropriate error
     *  code being returned to QDOS.
     */
    (void) mt_frjob( (jobid_t)-1, (long)code );
}

