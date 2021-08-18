/*  rand(3)
 *
 *  Author: Terrence W. Holm          Nov. 1988
 *
 *
 *  A prime modulus multiplicative linear congruential
 *  generator (PMMLCG), or "Lehmer generator".
 *  Implementation directly derived from the article:
 *
 *  S. K. Park and K. W. Miller
 *  Random Number Generators: Good Ones are Hard to Find
 *  CACM vol 31, #10. Oct. 1988. pp 1192-1201.
 *
 *
 *  Using the following multiplier and modulus, we obtain a
 *  generator which:
 *
 *  1)  Has a full period: 1 to 2^31 - 2.
 *  2)  Is testably "random" (see the article).
 *  3)  Has a known implementation by E. L. Schrage.
 */

#define __LIBRARY__

#include <stdlib.h>

#define  A        16807L    /*  A "good" multiplier */
#define  M   2147483647L    /*  Modulus: 2^31 - 1   */
#define  Q       127773L    /*  M / A               */
#define  R         2836L    /*  M % A               */


static long _lseed = 1L;


void srand  _LIB_F1_( unsigned int,  seed)
{
  _lseed = seed;
}


int rand   _LIB_F0_(void)
{
#if 0
  _lseed = A * (_lseed % Q) - R * (_lseed / Q);
#else
register long	  temp;
/*
 * The following shows how the expression was translated 
  _lseed = A * (_lseed % Q) - R * (_lseed / Q);

  _lseed = A * (_lseed - (_lseed / Q) ) - R * (_lseed / Q);
  temp = _lseed / Q;
  _lseed = A * (_lseed - temp * Q ) - R * ( temp );
  _lseed = A * _lseed - A * Q * temp - R * temp );
  _lseed = A * _lseed - ( A * Q * temp + R * temp );
  _lseed = A * _lseed - temp * ( A * Q + R );
  _lseed = A * _lseed - temp * M ;
  _lseed = A * _lseed - temp * 0x7FFFFFFF ;
  _lseed = A * _lseed - ( temp * ( 0x80000000 - 1 ) );
  _lseed = A * _lseed - ( temp * 0x80000000 - temp );
  _lseed = A * _lseed - ( temp << 31 ) + temp;
*/
  temp = _lseed / Q;
  _lseed = A * _lseed - ( temp << 31 ) + temp;
#endif

  if ( _lseed < 0 )
    _lseed += M;

  return( (int) _lseed );
}

