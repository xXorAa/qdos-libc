/*
 *      g e t p w n a m
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
#include <string.h>

struct passwd * getpwnam (name)
  const char * name;
{
    struct passwd * pwd;

    setpwent();
    while ( (pwd = getpwent()) != NULL) {
        if (strcmp (pwd->pw_name, name) == 0) {
            break;
        }
    }
    endpwent();
    return (pwd); 
}

