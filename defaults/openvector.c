/*
 *      _ O p e n V ec t o r
 *
 *   This routine defines the global vector _Open.  It is set to
 *   point to the internal library routine __Open by default.
 *
 *   AMENDMENT HISTORY
 *   ~~~~~~~~~~~~~~~~~
 *  31 Dec 94   DJW   - First version
 */

#define __LIBRARY__

#include  <fcntl.h>

int  (*_OpenVector)(const char *, int, ...) = __Open;



