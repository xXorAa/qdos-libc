/*
 *      _ Q o p e n _ i n
 *
 *  Default value for the list of characters that qopen() will
 *  treat as special characters that (potentially) need to be
 *  replaced in filenames by the corresponding characters in
 *  the _Qopen_out vector.
 *
 *  AMENDMENT HISTORY
 *  ~~~~~~~~~~~~~~~~~
 *  01 Jan 95   DJW   - First version
 */


#define __LIBRARY__

#include <fcntl.h>

char    _Qopen_in[] = "./\\";

