#define __LIBRARY__

#include <ctype.h>

#undef isascii

int isascii _LIB_F1_( int,  c)
{
    return ((unsigned)(c)<=127);
}
