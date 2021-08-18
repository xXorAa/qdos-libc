/*
 *      a r g u n p a c k
 *
 *  Unpack arguments.
 *
 *  This routine takes a command line and creates
 *  an array of argument pointers to strings (suitable
 *  for passing as the argv[] parameter to a program.,
 *
 *  The routine can be passed either an existing array
 *  of pointers (whose memory must have been allocated
 *  via malloc) or a NULL pointer.  In both cases any
 *  additional memory will be allocated dynamically.
 *
 *  Optionally a pointer to a function that is responsible
 *  for handling any further processing of any of the
 *  strings a function can be passed as a parameter.
 *
 *  Returns:
 *          -1      Error occurred.  All memory associated with
 *                  the array being built up will have been released.
 *	   other    Number of arguments found.
 *
 *  AMENDMENT HISTORY
 *  ~~~~~~~~~~~~~~~~~
 *  03 Sep 94   DJW   - First version.   This is based on the code that was
 *                      in the old _cmdparse() routine.
 *
 *  20 Aug 95   DJW   - Amended to work correctly on EPOC
 */

#define __LIBRARY__

#ifdef QDOS
#include <qdos.h>
#include <libgen.h>
#endif /* QDOS */

#ifdef EPOC
#include <cpoclib.h>
#endif /* EPOC */

#include <ctype.h>
#include <stdlib.h>
#include <string.h>

int   argunpack (const char *   cmdline,
                 char **  argvptr[],
                 int *    argcptr,
                 int (* function)(char *, char ***, int *))
{
    int     reply;
    size_t  len;
    char sc;
    const char *param;
    char *dup;

    /*
     *  See if we are setting up initial array
     *  If so initialise arrays
     */
    if (*argvptr == NULL) 
    {
        *argvptr = malloc (sizeof (char *));
        if (*argvptr == NULL) 
        {
            return -1;
        }
        *argcptr = 0;
    }
    /*
     *  We now work down the command line
     *  chopping out each argument in turn.
     *  Any surrounding quotes are removed.
     */
    for ( ; ; ) 
    {
        /*
         *  Get past any leading white space
         */
        while(isspace((unsigned char)*cmdline)) 
        {
            cmdline++;
        }
        if (*cmdline == '\0') 
        {
            break;
        }
        /*
         *  We next work out what character will terminate
         *  the argument.  We assume space of NULL character
         *  unless the next character is single or double
         *  quotes, in which case this becomes the character
         *  that terminates the argument.
         */
        sc = ' ';
        switch (*cmdline)
        {
            case '\'':
            case '"':
                    /* Next argument is string - store terminator */
                    sc = *cmdline++;
                    break;
            default:
                    break;
        }

        /*
         *  Parse until terminating character reached
         *  Any character preceded by a backslash escapes
         *  the next character which allows for embedded
         *  quote characters to be allowed through.
         *
         *  Allow for premature termination by NULL byte.
         */
        for ( param = cmdline ; *cmdline  ; cmdline++ ) 
        {
            /*
             *  If escape character, then skip
             *  over next character as well
             */
            if (*cmdline == '\\') 
            {
                cmdline++;
                continue;
            }
            if ((*cmdline == sc)
            ||  (sc == ' ' && isspace((unsigned char)*cmdline)) ) 
            {
                break;
            }
        }
        /*
         *  Create a copy of the string.
         *  Also compress any escape sequences.
         */
        len = cmdline - param;
        dup = (char *)malloc(len + 1);
        if (dup == NULL)
        {
            argfree (argvptr);
            return (-1);
        }
        sc = *cmdline;                  /* Save terminating character */
        *((char *)cmdline) = '\0';      /* Change it to NULL byte */
        (void) strccpy (dup, param);    /* copy compressing escape seq. */
        *((char *)cmdline) = sc;        /* restore terminating character */
        /*
         *  If we have a function to do wild card handling
         *  then call it.   If we do not, or if the function
         *  returns zero, then add it anyway.
         */
        reply = 0;
        if ((function == NULL)
        ||  ((reply = (*function)(dup, argvptr, argcptr)) == 0))
        {
            char * newptr;
            newptr = realloc (*argvptr, (size_t)(((*argcptr) + 2) * sizeof (char *)));
            if (newptr == NULL)
            {
                argfree(argvptr);
                return -1;
            }
            else
            {
                *argvptr = (char **)newptr;
            }
            (*argvptr)[*argcptr] = dup;
            *argcptr += 1;
        }
        else 
        {
            free (dup);
        }
        /*
         *  If we had a failure, then exit here
         */
        if (reply < 0) 
        {
            argfree (argvptr);
            return -1;
        }
        if (*cmdline++ == '\0') 
        {
            break;
        }
    }
    /*
     * Ensure the last argument is followed
     * by an entry containing NULL
     */
    (*argvptr)[*argcptr] = NULL;
    return (*argcptr);
}

