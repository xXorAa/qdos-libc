/*
 *          b u f s p l i t
 *
 *  Routine to split a buffer into fields.
 *
 * Returns:
 *
 * AMENDMENT HISTORY
 * ~~~~~~~~~~~~~~~~~
 *  07 Dec 96   DJW   - First version
 */

#include <libgen.h>
#include <string.h>

static  char * fieldsep = "\t\n";

size_t  bufsplit (char *  buffer,
                  size_t  maxcount,
                  char ** array)
{
    char *  ptr;
    char *  ptrend;
    size_t  count;
    size_t  reply;
    /*
     *  If 'buffer' is NULL, do nothing
     */
    if (buffer == NULL || *buffer == '\0')
    {
        return 0;
    }

    /*
     *  If other two parameters are 0, then
     *  simply change list of field seperators.
     */
    if (maxcount == 0 && array == NULL)
    {
        fieldsep = strdup(buffer);
        return 0;
    }

    /*
     *  Now work through the buffer looking for field
     *  seperators, and setting the pointer array up
     *  accordingly.   Once the end of the buffer has
     *  been reached, all subsequent entries in the
     *  pointer array are set to point to the NULL
     *  byte at the end of the string.
     */
    for (count = 0, reply=1, ptr=buffer, ptrend = buffer + strlen(buffer) ; 
                    count < maxcount ; count++)
    {
        array[count] = ptr;
        if (ptr < ptrend)
        {
            char * p;
            p = strpbrk (ptr, fieldsep);
            ptr = (p == NULL) ? ptrend : p + 1;
            reply++;
        }
    }
    return (reply);     
}

