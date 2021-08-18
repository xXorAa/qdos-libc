/*
 *      c o n s e t u p
 *
 *  This file contains the vector that is used to determine
 *  the default console initialisation routine.
 *
 *  The default routine specified here takes the following actions:
 *      a)  Checks to see whether console channel inherited from
 *          parent job - if so the following steps is suppressed.
 *      b)  Clears the console widnow, and sets it up as defined
 *          in the _condetails global variable.
 *
 *  If the user wishes to use suppress the console initialisation
 *  routine (normally because he is doing his own initialisation
 *  at a later stage in the main program code), then he can include
 *  a line of the form:
 *
 *      void (*_consetup)() = NULL;
 *
 *  in his own program at global scope). This will mean that
 *  the code that handlesconsole initialisation will be omitted.
 *  with an approriate reduction in program size.
 *
 *  It is also possible for the user to specify an alternative
 *  console initialisation routine by including a line of the form
 *
 *      void (*consetup)() = my_routine;
 *
 *  There is a standard alternative routine called 'consetup_title'
 *  that is supplied.   This adds a standardised menu bar to the
 *  top of the screen.
 *
 *  AMENDMENT HISTORY
 *  ~~~~~~~~~~~~~~~~~
 *  31 Dec 93   DJW   - This vector put into its own source file in the
 *                      LIBC_DEFAULTS directory to make it easier for
 *                      users to set an alternative default.
 *
 *  03 Sep 94   DJW   - Underscore added to target name as part of implementing
 *                      name hiding within C68 libraries.
 */

#define __LIBRARY__

#include <qdos.h>

void    (*_consetup)() = _consetup_default;

