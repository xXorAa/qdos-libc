/*
 *      g e t p w e n t
 *      s e t p w e n t
 *      e n d p w e n t
 *
 *  Unix compatible routines for accessing password file
 *
 *  As we do not realy have such a file, we simulate having a
 *  file with a single entry for user "root" which is the
 *  standard Unix super-user.
 *
 *  AMENDMENT HISTORY
 *  ~~~~~~~~~~~~~~~~~
 *  20 Feb 94   DJW   - First version
 */

#include <pwd.h>
#include <stddef.h>

static struct passwd _passwd = {
    "root",                 /* login name */
    0,                      /* user id */
    0,                      /* group id */
    "",                     /* home directory */
    "",                     /* name of shell */

    "",                     /* password information */
    ""                      /* ??? */
    };

static int   _passwd_entry = 0;    /* Current password entry */

struct passwd * getpwent ()
{
    return (_passwd_entry == 0) ? NULL : &_passwd;
}

void    endpwent ()
{
    _passwd_entry = 0;
    return;
}

void    setpwent ()
{
    _passwd_entry = 0;
    return;
}

