/*
 *  Tables used internally by signals
 */

#include <signal.h>
#include <sys/signal.h>

/* default priorities */
struct SIG_PRIOR_R _defsigrp =  {           /* receive      */
                     4,4,4,4,0,0
                     };
struct SIG_PRIOR_S _defsigsp =  {           /* send         */
                     6,6,6,6,1,1,1,0,0 
                     };
struct SIG_PRIOR_S _defsigskp = {           /* send SIGKILL */
                     7,7,7,7,1,1,1,0,0
                     };

