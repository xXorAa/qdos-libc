/*                              g e t c h a r                              */
 
#include "stdiolib.h"

/*LINTLIBRARY*/

#undef getchar
int getchar F0()

{
  return _STDIO_GETC_(stdin);
}
