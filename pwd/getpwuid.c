/*
 *      g e t p w u i d
 *
 *  Unix and Posx compatible routine for reading names from the
 *  system password file.
 *
 *  As we do not realy have such a file, we simulate having a
 *  file with a single entry for user "root" which is the
 *  standard Unix super-user.
 *
 *  AMENDMENT HISTORY
 *  ~~~~~~~~~~~~~~~~~
 *  20 Feb 94   DJW   - First version
 */

#define _LIBRARY_SOURCE

#include <pwd.h>
#include <stddef.h>

struct passwd * getpwuid (uid)
  uid_t  uid;
{
    struct passwd * pwd;


    setpwent();
    while ((pwd = getpwent()) != NULL) {
        if (uid == pwd->pw_uid) {
            break;
        }
    }
    endpwent();
    return (pwd); 
}

