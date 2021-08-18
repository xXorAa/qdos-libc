/*
 *          q l m k n a m _ c
 *
 * Routine to allow directory names to contain .._ 
 * or ../ to go up a directory level.
 *
 * Returns:
 *      -1      Error occurred - details in errno
 *      value   Number of levels found
 *
 * AMENDMENT HISTORY
 * ~~~~~~~~~~~~~~~~~
 *  03 Oct 93   DJW   - Moved strcpy() to after check on length.
 *  08 Oct 93   DJW   - Allowed for ../ sequence as well as .._ for up level
 */


#define __LIBRARY__

#include <string.h>
#include <errno.h>

int _qlmknam  _LIB_F4_( char *,         dest,
                        const char *,   dir,
                        const char *,   name,
                        int,            maxlen) /* Maximum length of dest
                                                   (not including '\0') */
{
    const char *p;
    const char *p1;
    int i, j;

    for (i=0, p1=name, p = &dir[strlen(dir) - 1] ;
                        (j = strfnd( ".._", p1)) >= 0 
                         ||(j = strfnd( "../", p1)) >= 0 ;
                      i++)
    {
        p1 += j + 3;    /* Go past the .._ or ../ sequence */
        for( --p ; (*p != '_') && (p >= dir) ; p--)
        {
            ;
        }
    }
    j = p - dir + 1;
    if( j + strlen(p1) > maxlen)
    {
        errno = EINVAL;
        return -1;
    }
    (void) strncpy( dest, dir, j);
    (void) strcpy( &dest[j], p1);
    return i;
}

