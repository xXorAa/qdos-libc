/*
 *              a s s e r t
 *
 * Routine to print a failed assertion.
 *
 * AMENDMENT HISTORY
 * ~~~~~~~~~~~~~~~~~
 *  03 Sep 94   DJW   - Replaced references to _dpname by references to
 *                      _program_name as the _dpname variable is no longer
 *                      globally visible.
 */

#include <assert.h>
#include <string.h>
#include <unistd.h>
#include <qdos.h>

void _assert( mesg)
char *mesg;
{
    /* 
     *  N.B. We use level 1 I/O so that we do not force the whole
     *      stdio library to be included merely for an assertion.
     */
    (void) write (2, _prog_name, strlen(_prog_name));
    (void) write (2, " - ", (unsigned)3);
    (void) write (2, mesg, strlen(mesg));
    (void) write (2, "\n --- assertion failed ---\n",(unsigned)27);
    _exit(-1);
}

