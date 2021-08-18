#include <ctype.h>

#undef iscsym

int iscsym( c )
int c;
{
	return (isalnum(c) || (((unsigned int)(c) & 127U) == 0x5f));
}
