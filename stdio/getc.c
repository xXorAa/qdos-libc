/*                                 g e t c                                 */

#include "stdiolib.h"

/*LINTLIBRARY*/

#undef getc
int getc F1(register FILE *, fp)

{
  return _STDIO_GETC_(fp);
}
