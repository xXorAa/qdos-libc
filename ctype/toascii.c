#include <ctype.h>

#undef toascii

int toascii( c )
int c;
{
	return ((unsigned int)(c) & 127U);
}
