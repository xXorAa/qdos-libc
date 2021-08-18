/*
 *     s i g n o m s g
 *
 *  Default message used if signal handler cannot be found.
 *  If set to NULL, then no message is ouput.
 *
 */

#include <sys/signal.h>

char  * __SigNoMsg = "*** SIGNAL extension not loaded ***\n";
