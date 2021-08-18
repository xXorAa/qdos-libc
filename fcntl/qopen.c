/*
 *      q o p e n
 *
 *  This is designed to act as a wrapper to open() to
 *  handle automatic translation of '/' and '.' characters
 *  in filenames to the QDOS/SMS standard of '_'.
 *
 *  It is automatically invoked by the fcntl.h header
 *  file if _USE_QOPEN is defined.
 *
 *  AMENDMENT HISTORY
 *  ~~~~~~~~~~~~~~~~~
 *  30 Dec 94   DJW   - First version
 */

#define  __LIBRARY__

#include <fcntl.h>
#include <libgen.h>
#include <limits.h>
#include <string.h>
#include <unistd.h>

int qopen( const char *name, int mode, ...)
{
    char    newname[MAXNAMELEN];
    char    *ptr1, *ptr2;
    int     reply;

    ptr1 = NULL;
    ptr2 = (char *)name;
    /*
     *  See if special characters
     *  so translation is required.
     */
    if (strpbrk (name, _Qopen_in) != NULL) {
        ptr1 = strtrns (name, _Qopen_in, _Qopen_out, newname);

        /*
         *  For WRITE modes we need to find out if the file
         *  under the original name already exists, as in
         *  that case it gets precedence.
         */
        if ((mode & (O_WRONLY | O_RDWR)) != 0) {
            int fd;
            if ((fd = __Open(name,O_RDONLY)) >= 0) {
                (void) close (fd);
                ptr1 = NULL;
            }
        }
    }
    /*
     *  Now lets try the opens
     */
    if (ptr1 != NULL) {
        if ((reply = __Open (ptr1, mode))  >= 0) {
            return reply;
        }
    }
    return __Open (ptr2, mode);
}

