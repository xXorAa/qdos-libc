/*
 *      g e t g r e n t
 *      s e t g r e n t
 *      e n d g r e n t
 *
 *  Unix compatible routines for accessing group file
 *
 *  As we do not realy have such a file, we simulate having a
 *  file with a single entry for user "root" which is the
 *  standard Unix super-user group.
 *
 *  AMENDMENT HISTORY
 *  ~~~~~~~~~~~~~~~~~
 *  10 Sep 94   DJW   - First version
 */

#define __LIBRARY__

#include <grp.h>
#include <stddef.h>

static char * group_members[] = {
        "root",
        NULL
        };

static struct group _group = {
    "root",                 /* name of the group */
    "",                     /* encrypte group password */
    0,                      /* group id */
    group_members           /* vector of pointers to member names */
    };

static int   _group_entry = 0;    /* Current password entry */

/*
 *  On first call returns a pointer to the first group structure
 *  in the file.  Subsequent calls return the next entry in the
 *  file until end of file reached when a NULL pointer is returned.
 */
struct group * getgrent _LIB_F0_ (void)
{
    return (_group_entry == 0) ? NULL : &_group;
}

/*
 *  Close the group file when processing is complete
 */
void    endgrent _LIB_F0_(void)
{
    _group_entry = 0;
    return;
}

/*
 *  Rewind the "group" file back to its start.
 *  Typically used to allow repeated searches
 */

void    setgrent _LIB_F0_(void)
{
    _group_entry = 0;
    return;
}

