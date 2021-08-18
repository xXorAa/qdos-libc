/*
 *              c d i r
 *
 * Routine to change the current directory path
 * If passed a null tries to go up a level, if
 * passed a string starting with a device then
 * replaces the current directory, else appends
 * the passed string to the current directory
 * path.
 *
 * AMENDMENT HISTORY
 * ~~~~~~~~~~~~~~~~~
 */

#define __LIBRARY__

#include <qdos.h>
#include <string.h>
#include <stdlib.h>
#include <errno.h>

int _cd  _LIB_F2_( char *,  actdir,     \
                   char *,  str)
{
    size_t i;
    short j;
    int newextra, oldextra;
    int dev;
    char *p;
    char string[50];

    /*
     *  If a real directory asked for,
     *  then just change actual directory
     */
    if( str && *str && isdevice( str, &newextra)) 
    {
        (void) strcpy( string, str );
        /*
         *  If its a real directory device, 
         *  ensure there's a '_' on the end
         */
        if( str[strlen(str)-1] != '_' && (newextra & DIRDEV)) 
        {
            (void) strcat( string, "_" );
        }
        _setcd(actdir,string);
        return 0;
    }
    /*
     *  Get current directory setting
     */
    (void) _getcd(actdir, string, (int)sizeof(string));
    dev = isdevice( string, &oldextra );
    /*
     *  Old directory is not a device either,
     *  or is only a simple device
     */
    if( dev == 0 || (oldextra & (DIRDEV | NETDEV)) == 0 ) 
    {
        errno = ENOTDIR;
        return -1; /* Can only move on directory devices */
    }

    /*
     *  Go up directory levels
     */
    for( ; !strfnd( ".._", str); str += 3 ) 
    {
        for( j = 0, p = string; *p; p++) 
        {
            /* Count the number of '_' s */
            if (*p == '_') 
            {
                j++;
            }
        }
        /*
         *  Check that path name is not empty
         *  (already at device name only !!)
         */
        if( j <= 1 ) 
        {
            errno = ENOENT;
            return -1;
        }
        /*
         *  Did old device started with a network number?
         *  If so, ensure we do not go up past it
         */
        if( oldextra & NETDEV) 
        {
            /*
             *  Cannot go up - already at
             *  net device name only
             */
            if( j <= 2) 
            {
                errno = ENOTDIR;
                return -1;
            }
        }
        /* 
         *  Back up to the last '_',
         *  and truncate all after it
         */
        for( i = strlen( string ) - 2; string[i] != '_' ; i--) 
        {
            ;
        }
        string[i+1] = '\0';
    }

    if(*str) 
    {
        /* There is more - go down again */
        if( strlen( string) + strlen( str ) > MAXNAMELEN - 1) 
        {
            errno = ENAMETOOLONG;
            return -1;
        }
        /* Extend directory path */
        (void) strcat( string, str);
        if( str[strlen(str)-1] != '_' && !(oldextra & NETDEV)) 
        {
            (void) strcat( string, "_" );
        }
    }
    /*
     *  Remove any consecutive multiple '_' s
     */
    for( p = string; *p; p++) 
    {
        if(*p == '_') 
        {
            while( *(p+1) == '_' )  
            {
                (void) strcpy( p+1, p+2);
            }
        }
    }
    /*
     *  Remove any leading spaces or tabs
     */
    for( p = string; *p; p++) 
    {
        while(*p == ' ' || *p == '\t') 
        {
            (void) strcpy( p, p+1);
        }
    }
    /*
     *  Store result
     */
    _setcd (actdir, string);
    return 0;
}

