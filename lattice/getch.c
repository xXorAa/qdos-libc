/*
 *          g e t c h
 *
 *  Lattice compatible routines to get a byte
 *  from a console channel, or push one back.
 *
 *  Amendment History
 *  ~~~~~~~~~~~~~~~~~
 *  20 Oct 92   DJW     Added getche() routine to complete set.
 *
 *  13 Apr 94   EAJ     Calls io_fbyte or equivalent through _readkybd vector
 *                      Also changed cast, so characters returned are always > 0
 */


#define __LIBRARY__

#include <qdos.h>
#include <stdio.h>

static int pushc = -1;

/*
 *  Get character with no echo
 */
int getch   _LIB_F0_ (void)
{
    char c1;
    int c;

    if( pushc != -1) {
        c = pushc;
        pushc = -1;
    } else {
        (void) (*_readkbd)( _conget(), (timeout_t)-1, &c1);
        c = (int)((unsigned char)c1);
    }
    return c;
}

/*
 *  Get character with echo
 */
int   getche  _LIB_F0_(void)
{
    int c = getch();
    (void) io_sbyte(_conget(), (timeout_t)-1, (unsigned char)c);
    return (c);
}

/*
 *  Unget character
 */
int ungetch  _LIB_F1_( int, c)
{
    pushc = c;
    return c;
}

