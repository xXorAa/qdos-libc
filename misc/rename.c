/*
 *      r e n a m e
 *
 * Routine to rename a file
 * Adds default directory to name if
 * name doesn't start with a device.
 *
 *  AMENDMENT HISTORY
 *  ~~~~~~~~~~~~~~~~~
 *  25 Jan 95   DJW   - Added 'const' keywords to parameter definitions
 */

#define __LIBRARY__

#include <qdos.h>
#include <stdio.h>
#include <errno.h>

int rename( old, newname )
  const char *old;
  const char *newname;
{
    char olds[MAXNAMELEN+1];
    char news[MAXNAMELEN+1];

    if ( (! _mkname(olds, old))
    ||   (! _mkname(news, newname)) ) {
        return -1;
    }

    /* Now call the QDOS rename routine */
    if( io_rename( olds, news ) ) {
        errno = EOSERR;
        return -1;
    }
    return 0;
}

