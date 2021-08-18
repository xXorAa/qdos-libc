#include <ctype.h>

#undef tolower

int tolower( c )
int c;
{
    return (isupper(c)?((c)+('a'-'A')):(c));
}
