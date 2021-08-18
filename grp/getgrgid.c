/*
 *      g e t g r g i d
 *
 *  Unix and Posx compatible routine for reading names from the
 *  system "group" file.
 *
 *  As we do not realy have such a file, we simulate having a
 *  file with a single entry for user "root" which is the
 *  standard Unix super-user.
 *
 *  AMENDMENT HISTORY
 *  ~~~~~~~~~~~~~~~~~
 *  10 Sep 94   DJW   - First version
 */

#define __LIBRARY__

#include <grp.h>
#include <stddef.h>

struct group * getgrgid _LIB_F1_(gid_t,  gid)
{
    struct group * grp;

    setgrent();
    while ((grp = getgrent()) != NULL) {
        if (gid == grp->gr_gid) {
            break;
        }
    }
    endgrent();
    return (grp); 
}

