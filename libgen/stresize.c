/*
 *      s t r e s i z e . c
 *
 *  Routine that can be used to calculate the size of target
 *  buffer that would be required by a strecpy() or streadd()
 *  call.
 *
 *  AMENDMENT HISTORY
 *  ~~~~~~~~~~~~~~~~~
 *  17 Nov 97   DJW   - First version.
 */

#define __LIBRARY__

#include <stddef.h>

#ifndef NOLIBGEN
 #ifdef QDOS
  #include <libgen.h>
  #include <qdos.h>
 #endif /* QDOS */
 #ifdef EPOC
  #include <cpoclib.h>
 #endif /* EPOC */
#else
int  	__Stresize (const char * input,
		           const char * exceptions,
                   const char * escape);
#endif /* NOLIBGEN */

int  	stresize ( const char * input,
                    const char * exceptions)
{
	return __Stresize(input, exceptions, NULL);
}

