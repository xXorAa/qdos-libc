/*
 *      s i g f i l l s e t
 *
 *  POSIX compatible routine to initialise and fill a signal set.
 *
 *  AMENDMENT HISTORY
 *  ~~~~~~~~~~~~~~~~~
 *  24 Jan 94   DJW   - First version.
 *   7 Feb 95    RZ   - Changed to set all signals regardless in a way that
 *                      did not need the signals to be named explicitly.
 */

#include <signal.h>

int sigfillset (set)
  sigset_t  *set;
{
    /*
     *  Initialise set with all standard signals
     */

/*  
  This is the long version!

    *set =  (1 << SIGABRT)  |
            (1 << SIGALRM)  |
            (1 << SIGFPE)   |
            (1 << SIGHUP)   |
            (1 << SIGILL)   |
            (1 << SIGINT)   |
            (1 << SIGKILL)  |
            (1 << SIGPIPE)  |
            (1 << SIGQUIT)  |
            (1 << SIGSEGV)  |
            (1 << SIGTERM)  |
            (1 << SIGUSR1)  |
            (1 << SIGUSR2);
*/

    *set = (sigset_t) (2<<NSIG)-1; 

    return 0;
}




