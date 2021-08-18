/*
 *      s t r c a d d _ c
 *
 *  Unix compatible routine to copy a string compressing
 *  the C language escape sequences to the equivalent
 *  character.  A NULL byte is appended to the end.  The
 *  target area must be large enough to hold the result,
 *  but an area the same size as the source is guarteed
 *  to be large enough.
 *
 *  Returns a pointer to the NULL byte terminating the target.
 *
 *  AMENDMENT HISTORY
 *  ~~~~~~~~~~~~~~~~~
 *  29 Aug 94   DJW   - First version
 *
 *  20 Aug 97   DJW   - Amended to work correctly on EPOC (Psion 3a)
 */

#define __LIBRARY__

#ifndef NOLIBGEN
 #if QDOS
  #include <libgen.h>
  #include <qdos.h>
 #elif EPOC
  #include <cpoclib.h>
 #else
  #include <libgen.h>
 #endif /* QDOS */
#else
 int     _CescInt (int c);
 int     _HexInt (int c);
 int     _OctInt (int c);
#endif /* NOLIBGEN */

#include <string.h>

char *  strcadd (char * output, const char * input)
{
    int    i, j, k, c;

    do {
        c = (unsigned char) *input++ ;
        if (c != '\\') 
		{
            *output++ = (char)c;
            continue;
        }
        c = (unsigned char) *input++;
        /*
         *  Allow for octal sequences
         */
        if (_OctInt(c) >= 0) 
		{
            for (i=0,j=0; (j < 3) && i<32 && (k=_OctInt(c)) >= 0; j++) 
			{
                i = 8*i + k;
                c = (unsigned char) *input++;
            }
            input--;
            *output++ = (char)i;
            continue;
        }
        /*
         *  allow for hexadecimal sequences
         */
        if (c == 'x') 
		{
            c = (unsigned char) *input++;
            for (i=0,j=0; (j < 2) && i<16 && (k=_HexInt(c)) >= 0; j++) 
			{
                i = 16*i + k;
                c = (unsigned char) *input++;
            }
            input--;
            *output++ = (char)i;
            continue;
        }
		/*
		 *	C escape sequences
		 */
        if ((i=_CescInt(c)) >= 0) 
		{
            *output++ = (char)i;
            continue;
        }
		/*
		 *  Treat other escaped characters as character
		 */
        *output++ = (char)c;

    } while (*input);

    *output = '\0';
    return (output);
}


