/*
 *  g m a t c h 
 *
 *  Unix compatible routine to match a pattern using the same
 *  wildcard algorithm as the shell.
 *
 *  AMENDMENT HISTORY
 *  ~~~~~~~~~~~~~~~~~
 *  03 Sep 94   DJW   - First version.  Basically the old internal routine
 *                      gmatch() that was used within the fnmatch() routine.
 */

#include <libgen.h>
#include <string.h>

#define NOT '^'

/*
 *  Internal routine.
 *  Examine list of characters inside [], check for match
 */
static char *cclass (const char * p,
                     unsigned int sub)
{
    unsigned int c, d;
    int notfound, found;

    /*
     *  NOT specifier detected
     */
    if(( notfound = *p == NOT ) != 0) {
        p++; 
    }
    /*
     *  Set default to return if doesnt match
     */
    found = notfound;
    /* 
     *  Go through characters in [   ]
     */
    do {
        if( *p == '\0' ) {
            return NULL; /* Definately doesn't match */
        }
        c = *p;
        /*
         *  Range asked for ?
         */
        if( p[1] == '-' && p[2] != ']') {
            d = p[2]; /* Get second character in range */
            p++; /* Go past character */
        } else {
            d = c; /* No range, d = same character */
        }
        /*
         *  Check if character matches or is in range
         *  If so, set found for return
         */ 
        if( c == sub || c <= sub && sub <= d) {
            found = !notfound;
        }
    } while( *++p != ']');
    /*
     *  Return new pointer if found,
     *  NULL otherwise
     */
    return ( found ? (char *)(p+1) : NULL );
}


int gmatch (const char * str,
            const char * pat)
{
    unsigned char sc, pc;

    if (str == NULL || pat == NULL) {
        return(0);
    }

    /*
     *  Get the first pattern character
     */
    while ((pc = *pat++ ) != '\0') {
        sc = *str++; /* Get the next string character */
        switch (pc) {
        case '[': /* List of alternate characters */
            if ((pat = cclass( pat, sc)) == NULL) {
                return 0;
            }
            break;
        case '?': /* Only fail on end of string */
            if (sc == 0) {
                return(0);
            }
            break; /* Returns true */
        case '*':
            str--; /* Go back to start of string */
            do {
                if (*pat == '\0' || gmatch(str, pat)) {
                    return(1);
                }
            } while (*str++ != '\0');
            return(0);
        default:
            if (sc != pc) {
                return(0);
            }
        }
    }
    return (*str == 0);
}

