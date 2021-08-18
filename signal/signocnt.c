/*
 *     s i g n o c n t
 *
 *  Count of times message should be output.
 *  -1      means output the message, and then abort the program
 *  other   output the message up to the number of times defined.
 */

#include <sys/signal.h>

short __SigNoCnt = 1;
