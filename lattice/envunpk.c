/*
 *                      e n v u n p k
 *
 *  Lattice compatible routine to unpack an buffer containing a number
 *  of consecutive environment strings into an array of pointers to 
 *  those strings.
 *
 *  Space for the pointer array is allocated dynamically as needed. 
 *  The global external variable 'environ' is updated with the address
 *  of the pointer array.  Any memory associated with the old pointer
 *  array is released.
 *
 *  Returns:
 *  ~~~~~~~
 *      -1      Error allocating memory
 *      >=0     Number of strings put into arrays
 *
 *  Amendment History
 *  ~~~~~~~~~~~~~~~~~
 *  24 Sep 92  DJW  -   First Version
 */

#define __LIBRARY__

#include <stdlib.h>
#include <string.h>
#include <unistd.h>

int envunpk  _LIB_F1_(char *, env)
{
    char *p, **e;
    int  argc;

    /*
     *  Start by counting the number of environment strings
     */
    for (argc=0, p=env; *p ; argc++) 
    {
        p += strlen(p) + 1;
    }

    /*
     *  Allocate the memory to hold the new pointer array,
     *  (and de-allocate the old memory)
     */
    if ((e = realloc(environ, (argc + 2) * sizeof (char *))) == NULL) 
    {
        return (-1);
    } 
    else 
    {
        environ = e;
    }
    /*
     *  Now build up the array
     */
    for (p = env, e = environ; *p; p += strlen(p) + 1) 
    {
        *e++ = p;
    }
    *e = NULL;              /* Set last one to NULL */
    return (argc);
}

