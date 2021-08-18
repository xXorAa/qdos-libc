/*
 *      c m d c h a n s
 *
 *  This file contains the vector that is used to determine
 *  whether command line redirection of standard channels is
 *  to be supported for this program or not.
 *
 *  The default value as specified here is that command line
 *  redirection of standard channels IS supported.   If the user
 *  does not wish his program to support this option (or he knows
 *  that it would be inappropriate) then he can include a line of
 *  the form
 *
 *      long (*_cmdchannels)() = NULL;
 *
 *  in his own program at global scope). This will mean that
 *  the code that handles the redirection of channels via the
 *  command line will be omitted with an approriate reduction
 *  in program size.
 *
 *  AMENDMENT HISTORY
 *  ~~~~~~~~~~~~~~~~~
 *  31 Dec 93   DJW   - This vector put into its own source file in the
 *                      LIBC_DEFAULTS directory to make it easier for
 *                      users to set an alternative default.
 */

#define __LIBRARY__

#include <qdos.h>

long (*_cmdchannels)()  = _cmdchans;

