/*
 *          c m d w i l d
 *
 *  This file contains the vector that is used to determine
 *  whether wildcard expansion of command line parameters is
 *  to occur (assuming that command line parameters are being
 *  supported in the first place).
 *
 *  The default value as specified here is that command line
 *  expansion IS NOT supported.   If the user wishes to use this
 *  option and is happy with the default routine supplied for
 *  this purpose (which works like UNIX shells), then he can
 *  include lines of the form
 *
 *      long (*_cmdchannels)() = NULL;
 *
 *  in his own program at global scope). This will mean that
 *  the code that handles wild card expansion will be included
 *  with an approriate increase in program size.
 *
 *  AMENDMENT HISTORY
 *  ~~~~~~~~~~~~~~~~~
 *  31 Dec 93   DJW   - This vector put into its own source file in the
 *                      LIBC_DEFAULTS directory to make it easier for
 *                      users to set an alternative default.
 *
 *  03 Sep 94   DJW   - The default value changed to NULL.  This is a
 *                      side-effect of revising the start-up code to 
 *                      use the new argunpack() routine.
 */

#define __LIBRARY__

#include <qdos.h>

int (*_cmdwildcard)() = NULL;

