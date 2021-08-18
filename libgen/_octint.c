/*
 *	_ O c t I n t . c
 *
 *  Support routine to handle octal to integer
 *  conversion of a character.  Specifically
 *  written to not need any data areas so
 *  that it can be used from a DLL.
 *
 *  Returns:
 *	-ve	Not a octal character
 *	>= 0	Numeric representation of octal character
 *
 *  AMENDMENT HISTORY
 *  ~~~~~~~~~~~~~~~~~
 *  20 Aug 97   DJW   - First version.  Wrutten to allow the
 *                      libgen strxxx family of routines to
 *                      work correctly in DLL tye situations
 *                      where no data is allowed.
 */

#define __LIBRARY__

#ifdef EPOC
#include <cpoclib.h>
#endif

#ifdef QDOS
#include <libgen.h>
#endif /* QDOS */


int     _OctInt (int c)
{
    switch (c) {
    case '0':
    case '1':
    case '2':
    case '3':
    case '4':
    case '5':
    case '6':
    case '7':
            return (c - '0');

    default:
            return (-1);
    }
}
