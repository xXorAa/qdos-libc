/*
 *  f n m a t c h 
 *
 * Match a pattern returning 1 on match, 0 otherwise
 *
 *  AMENDMENT HISTORY
 *  ~~~~~~~~~~~~~~~~~
 *  28 May 94   DJW   - Added casts to use of ctype.h macros for correct
 *                      handling of characters outside the range 0 to 127.
 *
 *  03 Sep 94   DJW   - Made the gmatch() routine into its own freestanding
 *                      routine (it is part of the libgen.h routines)
 */

#define __LIBRARY__

#include <qdos.h>
#include <ctype.h>
#include <libgen.h>
#include <string.h>

int fnmatch _LIB_F2_ (char *, str, \
                      char *, pat)
{
    char s[50],p[50];
    char *ptr;

    /*
     *  Remove .._ from names
     */
    while(strfnd( ".._", str) == 0) 
    {
        str += 3;
    }
    while( strfnd( ".._", pat) == 0) 
    {
        pat += 3;
    }
    /*
     *  Force everything to upper case
     */
    for( ptr = s; *str != 0; str++ ) 
    {
        *ptr++ = (char)toupper((unsigned char)*str);
    }
    *ptr  = '\0';
    for( ptr = p; *pat != 0; pat++ ) 
    {
        *ptr++ = (char)toupper((unsigned char)*pat);
    }
    *ptr  = 0;
    return gmatch( s, p);
}

