/*
 *      c m d p a r a m s
 *
 *  This file contains the vector that is used to determine
 *  whether command line parameters are to be accepted
 *  by the program or not.
 *
 *  The default value as specified here is that command line
 *  parameters ARE accepted.   If the user knows that his
 *  program will not want to use command line parameters,
 *  then he can include a line of the form
 *
 *      void (*_cmdparams)() = NULL;
 *
 *  in his own program at global scope). This will mean that
 *  the code that handles the parsing of the command line and
 *  the buidling of the argv parameter array will be omitted
 *  with an approriate reduction in program size.
 *
 *  AMENDMENT HISTORY
 *  ~~~~~~~~~~~~~~~~~
 *  31 Dec 93   DJW   - This vector put into its own source file in the
 *                      LIBC_DEFAULTS directory to make it easier for
 *                      users to set an alternative default.
 *
 *  04 Sep 94   DJW   - Changed to use the argunpack() routine
 *                      
 */

#define __LIBRARY__

#include <qdos.h>

int (*_cmdparams)() = _argunpack;

