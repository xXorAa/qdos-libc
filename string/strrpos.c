/*
 *      s t r r p o s
 *
 *  Routine to search a string for last occurence of a specified
 *  character and return its position in the string.
 *
 *  AMENDMENT HISTORY
 *  ~~~~~~~~~~~~~~~~~
 *  26 Jan 95   DJW   - Added 'const' keyword to parameter definitions
 */

#include <string.h>

int strrpos (s, c)
  const char * s;
  int    c;
{
    char *reply;

    if ((reply = strrchr (s, c))==NULL) {
        return -1;
    }
    return (int)(reply - s);
}

