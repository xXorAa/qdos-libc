/*
 *  Default Program end message timeout.
 *
 *  This is the timeout that will be displayed used a program
 *  on closedown as long as stdout and stderr are console
 *  channels, and that this is the owner job of the channels.
 *
 *  The programmer can supply an alternative value.
 */

#include <sms.h>

timeout_t _endtimeout = -1;         /* Wait forever */

