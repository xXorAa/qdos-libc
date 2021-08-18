/*
 *              m k d i r
 *
 *   Unix compatible routine to create a directory
 *  (on a system that supports this such as the Miracle
 *  Systems hard disk).
 *
 *  Returns:
 *      success     0
 *      failure     -1   and sets errno (and if relevant) _oserr.
 *
 * AMENDMENT HISTORY
 * ~~~~~~~~~~~~~~~~~
 *  11 Jul 93   DJW   - Removed assumption that io_mkdir() sets _oserr.
 *
 *  26 Jan 94   DJW   - Changed definition slightly to allow for a second
 *                      parameter (which is not used). On Unix systems this
 *                      would be the mode to set on the directory.
 *
 *  12 Oct 96   DJW   - If name supplied ends in the directory seperator
 *                      character then this is removed before trying to
 *                      create a directory with the given name.
 *                      (problem reported by Jonathan Hudson).
 */

#include <sys/stat.h>
#include <fcntl.h>
#include <qdos.h>
#include <errno.h>
#include <unistd.h>
#include <string.h>
#include <limits.h>

int mkdir  ( const char * name, ... )
{
    int     fd;
    int     reply;
    char    buffer[MAXNAMELEN];
    char    *ptr;

    /*
     *  NULL paths are not allowed
     */
    if (name == NULL || *name == '\0')
    {
        errno = ENOENT;
        return -1;
    }
    /*
     *  Copy the filename and then check if it
     *  finishes with underscore (the directory
     *  seperator character) and if so remove it.
     */
    ptr = strcpy (buffer,  name) + strlen(name) - 1;
    if (*ptr == '_')
    {
        *ptr = '\0';
    }
    /*
     *  Create a file of the desired name
     */
    if((fd = open( buffer, O_CREAT | O_RDWR))== -1) {
        return -1;
    }
    /*
     *  Now do the low level call to convert to directory
     *  This will fail on systems that do not support
     *  directories, so we need to remove the file we
     *  have just created in this case.
     */
    if( (reply=io_mkdir( getchid( fd ))) != 0) {
        (void) close( fd );
        (void) unlink( buffer );
        _oserr = reply;
        errno = EOSERR;
        return -1;
    }
    (void) close( fd );
    return 0;
}

