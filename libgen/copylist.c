/*
 *          c o py l i s t
 *
 *  Routine to copy a file into meory with all 
 *  all newlines changed to NULL characters.
 *
 * Returns:
 *      NULL if any problem.
 *      address of memory if OK.
 *
 * AMENDMENT HISTORY
 * ~~~~~~~~~~~~~~~~~
 *  07 Dec 96   DJW   - First version
 */

#include <libgen.h>
#include <fcntl.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/stat.h>

char * copylist (const char *filename, 
                 size_t * sizeptr)

{
    struct stat statbuf;
    int     fd;
    char *  reply;
    char *  ptr;

    if ((fd = open(filename,O_RDONLY)) < 0)
    {
        return NULL;
    }
    if (fstat(fd,&statbuf) != 0)
    {
        (void)close (fd);
        return NULL;
    }
    *sizeptr = statbuf.st_size;
    if ((reply = malloc (statbuf.st_size)) == NULL)
    {
        (void)close (fd);
        return NULL;
    }
    if (read (fd, reply, statbuf.st_size) != statbuf.st_size)
    {
        free (reply);
        (void)close (fd);
        return NULL;
    }
    (void)close(fd);
    for (ptr = reply + statbuf.st_size ; ptr > reply ; )
    {
        if (*ptr == '\n')
        {
            *ptr = '\0';
        }
    }
    return reply;
}

