#include <ctype.h>

#undef toupper

int toupper( c )
int c;
{
    return (islower(c)?((c)-('a'-'A')):(c));
}
