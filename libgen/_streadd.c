/*
 *      _ s t r e a d d _ c
 *
 *  Support routine used by the strecpy() and streadd().
 *  Can also be used directly from elsewhere within the library.
 *
 *  Routine to copy a string expanding
 *  non-graphic characters to their equivalent C language
 *  escape sequencesr.  A NULL byte is appended to the end.
 *  The target area must be large enough to hold the result,
 *  but an area 4 times the size of the source is guaranteed
 *  to be large enough.
 *
 *  The exceptions string contains any characters that are
 *  not to be expanded.
 *
 *  The escape string contains any characters that are to
 *  be escpaed that otherwise would not be.
 *
 *  Returns a pointer to the NULL byte at the end of the
 *  target string (cf strecpy()).
 *
 *  AMENDMENT HISTORY
 *  ~~~~~~~~~~~~~~~~~
 *  29 Aug 94   DJW   - First version
 *
 *  24 Jan 95   DJW   - Missing 'const' keyword added to function definition.
 *
 *  17 Nov 97   DJW   - Changed to use _IntCesc() support routine so that it
 *                      is suitable for inclusion into a DLL.
 */

#define __LIBRARY__

#include <ctype.h>
#include <string.h>

#ifndef NOLIBGEN
 #ifdef QDOS
  #include <libgen.h>
  #include <qdos.h>
 #endif /* QDOS */
 #ifdef EPOC
  #include <cpoclib.h>
 #endif /* EPOC */
#else
 int     _IntCesc (int c);
#endif /* NOLIBGEN */

char *  __Streadd ( char *       output,
                   const char * input,
                   const char * exceptions,
                   const char * escape)
{
    int c, i;

    do {
        c = (unsigned char)*input++;
        /**
         *  printable characters are simply output unchanged
         **/
        if (isprint(c))  
		{
            if (escape && (strchr(escape,c) != NULL)) 
			{
                *output++ = '\\';
            }
            *output++ = (char)c;
            continue;
        }
        /**
         *  exception characters are output unchanged
         **/
        if (exceptions && strchr(exceptions, c)) 
        {
            *output++ = (char)c;
            continue;
        }
        /**
         *  Special character that needs escaping
         **/
        *output++ = '\\';
        /**
         *  For standard C ones use the abreviation
         **/
        if ((i=_IntCesc(c)) >= 0) 
        {
            *output++ = (char)i;
            continue;
        }
        /**
         *  For others output octal value
         **/
        *output++ = (char)('0' + (c >> 6));
        c &= 0x3f;
        *output++ = (char)('0' + (c >> 3));
        *output++ = (char)('0' + (c & 0x7));
    } while (*input);

    *output = '\0';
    return (output);
}

