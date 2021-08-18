/*
 *          o p e n _ q d i r
 *
 *  Routine to open a QDOS directory device to read 
 *  the list of files within.
 *
 *  AMENDMENT HISTORY
 *  ~~~~~~~~~~~~~~~~~
 *  10 Jul 93   DJW   - Removed assumption that io_open() sets _oserr.
 *  18 Aug 93   DJW   - Removed assumption that _oserr is set in this
 *                      routine - instead it now returns either a QDOS
 *                      error code (negative) or a C error code (0).
 *
 *  24 Jan 95   DJW   - Missing 'const' keyword added to function definition.
 */

#define __LIBRARY__

#include <qdos.h>
#include <stdlib.h>
#include <errno.h>

chanid_t open_qdir _LIB_F1_( const char *,   name)
{
    char fname[MAXNAMELEN+1];

    /*
     *  Ensure that the name includes
     *  a device, and if necessary add it
     */
    if (! _mkname(fname,name)) {
        return (chanid_t)0;
    }

    /*
     *  Open the directory using the full path
     */
    return (io_open( fname, (long)DIROPEN));
}

