/*
 *      _ Q o p e n _ o u t
 *
 *  Default value for the list of characters that qopen() will
 *  replace special characters that (potentially) need to be
 *  replaced in filenames as identified by the _Qopen_in vector.
 *
 *  NOTE.   If this vector is shorter than the _Qopen_in vector,
 *          then random characters could be picked up.
 *
 *  AMENDMENT HISTORY
 *  ~~~~~~~~~~~~~~~~~
 *  01 Jan 95   DJW   - First version
 */


#define __LIBRARY__

#include <fcntl.h>

char    _Qopen_out[] = "___";

