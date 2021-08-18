/*
 *  p o s e r r
 *
 * Routine to print out an operating system error message
 *
 * AMENDMENT HISTORY
 * ~~~~~~~~~~~~~~~~~
 * 29 Aug 94    DJW   - Removed newline at start of output (for
 *                      consistency with perror).
 *
 *  24 Jan 95   DJW   - Missing 'const' keyword added to function definition.
 */

#define __LIBRARY__

#include <qdos.h>
#include <stdio.h>
#include <errno.h>

int  poserr  _LIB_F1_ ( const char *, str )
{
    int save = _oserr;
    int err = -_oserr;      /* Negate the error as QDOS errors are -ve */

    if( !err )
        return _oserr;
    if( err > os_nerr || err < 0)
        err = 0;
    (void) fprintf( stderr, "%s: %s\n", str, os_errlist[err]);
    return ( _oserr = save );
}

