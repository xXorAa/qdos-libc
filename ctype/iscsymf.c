#include <ctype.h>

#undef iscsymf

int iscsymf( c )
int c;
{
	return (isalpha(c)||(((unsigned int)(c)&127U)==0x5f));
}
