/*
 *      s t r e c p y _ c
 *
 *  Unix compatible routine to copy a string expanding
 *  non-graphic characters to their equivalent C language
 *  escape sequencesr.  A NULL byte is appended to the end.
 *  The target area must be large enough to hold the result,
 *  but an area 4 times the size of the source is guaranteed
 *  to be large enough.
 *
 *  The exceptions string contains any characters that are
 *  not to be expanded.
 *
 *  Returns a pointer to the output string (cf streadd()).
 *  AMENDMENT HISTORY
 *  ~~~~~~~~~~~~~~~~~
 *  29 Aug 94   DJW   - First version
 *
 *  18 Nov 97   DJW   - Amended to work on EPOC (Psion 3a)
 */

#define __LIBRARY__

#include <stdlib.h>

#ifndef NOLIBGEN
 #ifdef QDOS
  #include <libgen.h>
 #endif /* QDOS */
 #ifdef EPOC
  #include <cpoclib.h>
 #endif /* EPOC */
#else
char *  __Streadd ( char *       output,
                   const char * input,
                   const char * exceptions,
                   const char * escape);
#endif /* NOLIBGEN */

char *  strecpy  (char *        output,
                  const char *  input,
                  const char *  exceptions)
{
    (void) __Streadd(output, input, exceptions, NULL);
    return (output);
}

