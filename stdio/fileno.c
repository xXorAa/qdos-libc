/*                               f i l e n o                               */
 
#include "stdiolib.h"

/*LINTLIBRARY*/

#undef fileno
int fileno F1(FILE *, fp)

{
  return _STDIO_FILENO_(fp);
}
