/*
 *      s t r e s i z e . c
 *
 *  Support routine used by _stresize() routine.
 *  Takes same additonal parameter as _streadd() so
 *  can be used internally inside libraries.
 *
 *  AMENDMENT HISTORY
 *  ~~~~~~~~~~~~~~~~~
 *  17 Nov 97   DJW   - First version.
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

int  	__Stresize ( const char * input,
                    const char * exceptions,
                    const char * escape)
{
    register size_t count = 1;
    int c, i;

    do 
    {
        c = (unsigned char)*input++;
        /**
         *  printable characters are simply output unchanged
         **/
        if (isprint(c))  
        {
            if (escape && (strchr(escape,c) != NULL)) 
            {
                count++;
            }
            count++;
            continue;
        }
        /**
         *  exception characters are output unchanged
         **/
        if (exceptions && strchr(exceptions, c)) 
        {
            count++;
            continue;
        }
        /**
         *  Special character that needs escaping
         **/
        /**
         *  For standard C ones use the abreviation
         **/
        if ((i=_IntCesc(c)) >= 0) 
        {
            count += 2;
            continue;
        }
        /**
         *  For others output octal value
         **/
        count += 4;
    } while (*input);

    return (count);
}

#ifdef TESTPROG
#include <stdio.h>

int main (int argc, char ** argv)
{
	printf ("Test of stresize() function\n");
	printf ("~~~~~~~~~~~~~~~~~~~~~~~~~~~\n");

	printf ("stresize(\"abcdef\") =  %d\n",stresize("abcdef"));
	for ( ; ; )
	{
	}
}

#endif /* TESTPROG */
