/*
 *	_ C e s c I n t . c
 *
 *  Support routine to handle C escape character
 *  to integer conversion of a character.  Specifically
 *  written to not need any data areas so that it can 
 *  be used from a DLL.
 *
 *  Returns:
 *	-ve	Not a C escape character
 *	>= 0	Internal numeric representation of C escape character
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

int     _CescInt (int c)
{
    switch (c) {
    case '0':
            return '\0';
    case 'a':
            return '\a';
    case 'b':
            return '\b';
    case 'f':
            return '\f';
    case 'n':
            return '\n';
    case 'r':
            return '\r';
    case 't':
            return '\t';
    case 'v':
            return '\v';
    default:
            return (-1);
    }
}
