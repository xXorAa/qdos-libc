/*                              p u t c h a r                              */

#include "stdiolib.h"

/*LINTLIBRARY*/

#undef putchar
int putchar F1(int, ch)

{
  return _STDIO_PUTC_(ch, stdout);
}
