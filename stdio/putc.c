/*                                 p u t c                                 */

#include "stdiolib.h"

/*LINTLIBRARY*/

#undef putc
int putc F2(int, ch, register FILE *, fp)

{
  return _STDIO_PUTC_(ch, fp);
}
