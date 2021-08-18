/*
 *      s t r c c p y _ c
 *
 *  Unix compatible routine to copy a string compressing
 *  the C language escape sequences to the equivalent
 *  character.  A NULL byte is appended to the end.  The
 *  target area must be large enough to hold the result,
 *  but an area the same size as the source is guarteed
 *  to be large enough.
 *
 *  AMENDMENT HISTORY
 *  ~~~~~~~~~~~~~~~~~
 *  29 Aug 94   DJW   - First version
 *
 *  20 Aug 97   DJW   - Amended to work on EPOC (Psion 3a)
 */

#define __LIBRARY__

#ifndef NOLIBGEN
 #ifdef QDOS
  #include <libgen.h>
 #endif /* QDOS */
 #ifdef EPOC
  #include <cpoclib.h>
 #endif /* EPOC */
#else
char *  strcadd (char * output, const char * input);
#endif /* NOLIBGEN */

char *  strccpy (char * output, const char * input)
{
    (void) strcadd(output, input);
    return (output);
}

