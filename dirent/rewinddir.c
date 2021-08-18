/*
 *  r e w i n d d i r
 *
 *  Reset directory to start
 *
 */


#include <dirent.h>

void rewinddir (dirp)
  DIR * dirp;
{
    seekdir (dirp, 0L);
    return;
}

