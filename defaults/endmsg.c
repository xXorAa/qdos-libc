/*
 *  Default Program end message.
 *
 *  This is the message that will be displayed by a program
 *  on closedown as long as stdout and stderr are console
 *  channels, and that this is the owner job of the channels.
 *
 *  The user can supply an alternative message, or suppress
 *  the option by setting up a NULL pointer in his own program.
 */

#include <sms.h>

char  *  _endmsg = "Press a key to exit";

