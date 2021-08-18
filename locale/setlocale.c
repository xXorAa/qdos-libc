/*
 *      s e t l o c a l e / l o c a l e c o n v
 *
 *  ANSI compatible routines to set and read locale.
 *
 *  We currently only support the default C/POSIX locale
 *
 *  AMENDMENT HISTORY
 *  ~~~~~~~~~~~~~~~~~
 *  29 Aug 93   DJW/KW  First version
 */

#include <locale.h>
#include <limits.h>
#include <string.h>

static struct lconv _locale =
        {
        ".", "", "", "", "", "", "", "", "", "",
        CHAR_MAX, CHAR_MAX, CHAR_MAX, CHAR_MAX,
        CHAR_MAX, CHAR_MAX, CHAR_MAX, CHAR_MAX
        };


struct lconv * localeconv (void)
{
    return (&_locale);
}



char * setlocale (int category, const char * locale)
{
    if (locale) {
        if (strcmp(locale, "") && strcmp(locale,"C") && strcmp(locale,"POSIX")) {
            return NULL;
        }
        /*
         *  Here i where the locale is set
         */
        switch (category) {
            case LC_ALL:
            case LC_COLLATE:
            case LC_CTYPE:
            case LC_MONETARY:
            case LC_NUMERIC:
            case LC_TIME:
                    break;
            default:
                    return NULL;
        }
    }

    /*
     *  Now the part that returns the current value
     */
    return ("C");
}

