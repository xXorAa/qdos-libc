/*
 *          p a t h f i n d 
 *
 *  Search for named file in named directories
 *
 *  pathfind searches the directories named in path for the named file.
 *  The directories named in path are separated by semicolons.  The
 *  mode parameter is a string of option letters chosen from the
 *  following list:
 *              Letter      Meaning
 *              ~~~~~~      ~~~~~~~
 *                r         readable
 *                w         writable
 *                x         executable
 *                f         normal file
 *                b         block special
 *                c         character special
 *                d         directory
 *                p         FIFO (pipe)
 *                u         set user ID bit
 *                g         set group ID bit
 *                k         sticky bit
 *                s         size nonzero
 *
 *  If the named file with all the characteristics specified by mode
 *  is found in any of the directories specified by path then pathfind()
 *  returns a pointer to a string containing the member of path
 *  followed by a directory separator character followed by name,
 *
 *  If name begins with a slash it is treated as an absolute path name 
 *  and path is ignored.
 *
 *  An empty path member is treated as the current directory.  In this
 *  case the unadorned file name is returned.
 *
 * AMENDMENT HISTORY
 * ~~~~~~~~~~~~~~~~~
 *  14 Dec 96   DJW   - First version
 */

#include <libgen.h>
#include <limits.h>
#include <string.h>
#include <sys/stat.h>

static  char foundname[MAXNAMELEN];

char *  pathfind (const char * path,
                  const char * name,
                  const char * mode)
{
    static struct {
        char    mode;
        mode_t  mask;
        } *pmodetable, modetable[] = {
            {'r', S_IRUSR},
            {'w', S_IWUSR},
            {'x', S_IXUSR},
            {'f', S_IFREG},
            {'b', S_IFBLK},
            {'c', S_IFCHR},
            {'d', S_IFDIR},
            {'p', S_IFIFO},
            {'u', 0},               /* S_ISUID is not supported on QDOS */
            {'g', 0},               /* S_ISGID is not supported on QDOS */
            {'k', 0},               /* sticky bit not supported by QDOS */
            {'\0',0}
            };

    struct stat statbuf;
    char    *ptr;
    mode_t  modemask;
    int     nonzero;
    int     length;

    for (ptr = (char *)mode, modemask = 0, nonzero=0 ; *ptr ; ptr++)
    {
        for (pmodetable = modetable; pmodetable->mode != '\0' ; pmodetable++)
        {
            if (pmodetable->mode == *ptr)
            {
                modemask |= pmodetable->mode;
                continue;
            }
            if (*ptr == 's')
            {
                nonzero = 1;
                continue;
            }
            /*
             *  Nothing is said in the description about what
             *  we do with invalid mode characters.  I assume
             *  we simply ignore them.
             */
            continue;
        }
    }
    /*
     *  Now do the work of looking for the file.
     */
    for (ptr = (char *)path ; *ptr ; )
    {
        if ((length = strpos (ptr,';')) == -1)
        {
            (void)strcpy (foundname, ptr);
        }
        else
        {
            (void)strncpy (foundname, ptr, length);
            foundname[length] = '\0';
        }
        (void) strcat (foundname, name);

        if (stat(foundname, &statbuf) == 0)
        {
            if (modemask == (modemask & statbuf.st_mode))
            {
                if (nonzero && statbuf.st_size != 0)
                {
                    return foundname;
                }
            }
        }
    }
    return NULL;
}

