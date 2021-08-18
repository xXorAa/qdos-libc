/*
 *                  _ m k n a m e
 *
 *  Internal library routine to build up a valid
 *  filename.   If a device name is not already
 *  present then the default data directory is added.
 *
 *  AMENDMENT HISTORY
 *  ~~~~~~~~~~~~~~~~~
 *
 *  24 Jan 95   DJW   - Missing 'const' keyword added to function definition.
 */

#define __LIBRARY__

#include <qdos.h>
#include <unistd.h>
#include <string.h>
#include <errno.h>

char *_mkname _LIB_F2_ ( char *,        dest, \
                         const char *,  name)
{
    char cwd[MAXNAMELEN+1];
    int  devtype;

    /*
     *  First do some sanity checks on the name
     */
    if(strlen(name) > MAXNAMELEN) 
    {
        errno = EINVAL;
        return (char *)NULL;
    }

    /*
     *  If no device passed, then put the 
     *  default data device in front
     */
    if( !isdevice( name, &devtype )) 
    {
        (void) getcwd(cwd,MAXNAMELEN);
        if(_qlmknam( dest, cwd, name, MAXNAMELEN)<0) 
        {
            return (char *)NULL;
        }
    } 
    else
    {
        (void) strcpy( dest, name);
    }

    return (dest);
}

