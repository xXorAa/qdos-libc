/*
 *      c r e a t
 *
 *  Unix compatible routine to creat a new file.
 *  Calls open with correct mode
 *
 *  AMENDMENT HISTORY
 *  ~~~~~~~~~~~~~~~~~
 *  25 Jan 95   DJW   - Added 'const' keyword to function parameters
 */

#define __LIBRARY__

#include <fcntl.h>

int creat  _LIB_F2_ ( const char *, name, \
                      mode_t,       mode)
{
    mode &= O_RAW; /* Msk off all bits but O_RAW */
    mode |= O_CREAT|O_TRUNC|O_WRONLY; /* Add create and truncate flags */
    return open( name, mode);
}
