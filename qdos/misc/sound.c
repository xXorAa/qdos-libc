/*
 *      s o u n d _ c
 *
 *  Make a sound. All parameters passed for the 8049 IPC.
 *  N.B.  Fields are byte reversed (Intel style)
 *
 *  21 Feb 93   DJW     Amended to use store the parameters in a structure
 *                      rather than an array as better code is generated, 
 *                      and also the code is clearer.
 *
 *  08 Nov 93   DJW   - Changed parameter types to short and char
 */

#define __LIBRARY__

#include <qdos.h>

#ifndef uchar
#define uchar unsigned char
#endif
#ifndef ushort
#define ushort unsigned short
#endif

static struct {
        uchar   command;
        uchar   paramlength;
        long    bitstouse;
        uchar   pitch1;
        uchar   pitch2;
        ushort  interval;
        ushort  duration;
        uchar   step;
        uchar   wrap;
        uchar   random;
        uchar   fuzz;
        uchar   reply;
        } params = { 0xA, 10, 0x00AAA,
                            0, 0, 0, 0, 0, 0, 0, 0, 
                            0x1 };

void do_sound _LIB_F8_( unsigned short,dur, \
                         unsigned char, pitch, \
                         unsigned char, pitch2, \
                         unsigned char, wrap, \
                         unsigned short,g_x, \
                         unsigned char, g_y, \
                         unsigned char, fuzz, \
                         unsigned char, rndm)
{
    params.pitch1   = pitch;
    params.pitch2   = pitch2;
    params.interval = (ushort)(((g_x & 0xFF) << 8) | (g_x >> 8));
    params.duration = (ushort)(((dur & 0xFF) << 8) | (dur >> 8));
    params.step     = g_y;
    params.wrap     = wrap;
    params.random   = rndm;
    params.fuzz     = fuzz;
    (void) mt_ipcom( (char *) &params );
    return;
}

