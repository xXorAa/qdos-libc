/*
 *	_ H e x I n t . c
 *
 *  Support routine to handle Hex to integer
 *  conversion of a character.  Specifically
 *  written to not need any data areas so
 *  that it can be used from a DLL.
 *
 *  Returns:
 *	-ve	Not a hex character
 *	>= 0	Numeric representation of hex character
 *
 *  AMENDMENT HISTORY
 *  ~~~~~~~~~~~~~~~~~
 *  20 Aug 97   DJW   - First version.  Wrutten to allow the
 *                      libgen strxxx family of routines to
 *                      work correctly in DLL tye situations
 *                      where no data is allowed.
 */

#define __LIBRARY__

#ifdef QDOS
 #include <libgen.h>
#endif /* QDOS */

#ifdef CPOC
 #include <cpoclib.h>
#endif /* CPOC */

int     _HexInt (int c)
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

    case 'a':
    case 'b':
    case 'c':
    case 'd':
    case 'e':
    case 'f':
            return (c - 'a' + 10);

    case 'A':
    case 'B':
    case 'C':
    case 'D':
    case 'E':
    case 'F':
            return (c - 'A' + 10);

    default:
            return (-1);
    }
}

