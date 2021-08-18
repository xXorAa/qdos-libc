/*
 *      g e t g r n a m
 *
 *  Unix and Posx compatible routine for reading names from the
 *  system 'group' file.
 *
 *  As we do not realy have such a file, we simulate having a
 *  file with a single entry for user "root" which is the
 *  standard Unix super-user.
 *
 *  AMENDMENT HISTORY
 *  ~~~~~~~~~~~~~~~~~
 *  10 Feb 94   DJW   - First version
 */

#define __LIBRARY__

#include <grp.h>
#include <string.h>

struct group * getgrnam _LIB_F1_(const char *,  name)
{
    struct group * grp;

    setgrent();
    while ((grp = getgrent()) != NULL) {
        if (strcmp (grp->gr_name, name) == 0) {
            break;
        }
    }
    endgrent();
    return (grp); 
}

