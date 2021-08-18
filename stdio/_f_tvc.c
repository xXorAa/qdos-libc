/*                               _ f _ t v c                               */

/* This code implements the %f, %g and %e formats for input conversion
 * of floating point numbers. It is called from _vfscanf().
 */

extern int __mpow10;

#include "stdiolib.h"
#include <math.h>

/*LINTLIBRARY*/

#define NEXTCH()	(nbytes++, ch = getc(fp))

#if '0'+1 != '1' || '1'+1 != '2' || '2'+1 != '3' || '3'+1 != '4' || \
    '4'+1 != '5' || '5'+1 != '6' || '6'+1 != '7' || '7'+1 != '8' || \
    '8'+1 != '9'
  << Violation of collating sequence assumption >>
#endif

char __xfptvc = 0;			/* linkage for library */

/* Status word bits */

#define TVC_EXPONENT	0x0001		/* exponent exists */
#define TVC_NEGATIVE	0x0002		/* negative */
#define TVC_EXPNEGATIVE	0x0004		/* exponent negative */
#define TVC_SCANZEROS	0x0008		/* leading zeros scanned off */
#define TVC_FRACTION	0x0010		/* fractional part seen */

/****************************************************************/
/* Assume that division or multiplication by FLT_RADIX is exact */
/****************************************************************/

int __tvc F5(FILE *, fp, int, width, VA_LIST *, argp, int, fptype, char *, ok)

{
  int ch;				/* look-ahead character */
  int nbytes;				/* bytes scanned */
  int fracpart;				/* fractional part of mantissa */
  longguard mant;			/* mantissa */
  longdouble Mantissa;			/* result */
  int exponent;				/* exponent */
  int digits;				/* significant digits */
  int status;				/* status word */
  long imantissa;			/* mantissa collection */
  int imantdigs;			/* digits collected */
  int gdigits;				/* guard digits */
  int normexp;				/* exponent for normalised number */
  int expoffset;			/* offset for exponent */
  longguard pow10;			/* guarded power of ten */
  static longdouble flt_radix = FLT_RADIX;/* exponent radix */
#ifdef	LMR
  static int ldbl_max_radix[sizeof(longdouble)/sizeof(int)] = {
#include "lmr.h"
  };
#else
  static longdouble ldbl_max_radix[1];
#endif

  ch           = getc(fp);
  status       = 0;
  nbytes       = 0;
  exponent     = 0;
  *ok          = 0;

#ifndef	LMR
  ldbl_max_radix[0] = LDBL_MAX / FLT_RADIX;
#endif

/* Leading sign bit */
  if (width != 0) {
    if (ch == '-') {
      status |= TVC_NEGATIVE;
      NEXTCH();
      width--;
    } else if (ch == '+') {
      NEXTCH();
      width--;
    }
  }

/* Skip leading zeros in integer part */
  while (width != 0 && ch == '0') {
    NEXTCH();
    width--;
    status |= TVC_SCANZEROS;
  }

/* Convert digits */
  imantissa     = 0;
  imantdigs     = 0;
  gdigits       = 0;
  digits        = 0;
  fracpart      = 0;
  mant.number   = 0.0;
  mant.guard    = 0.0;
  mant.exponent = 0;
  while (width != 0) {
    switch (ch) {
    case '0': case '1': case '2': case '3': case '4':
    case '5': case '6': case '7': case '8': case '9':
      if (digits >= 3*LDBL_DIG/2) {
	if ((status & TVC_FRACTION) == 0)
	  fracpart--;
      }
      else {
	if (digits != LDBL_DIG/2 && imantdigs < __Mipow10)
	  imantissa *= 10;
	else {
	  if (digits == LDBL_DIG/2)
	    mant.number = imantissa;
	  else {
	    mant.guard = mant.guard * __fpow10[imantdigs] + imantissa;
	    gdigits   += imantdigs;
	  }
	  imantissa = 0;
	  imantdigs = 0;
	}
	imantissa += ch - '0';
	imantdigs++;
	digits++;
	fracpart++;
      }
      NEXTCH();
      width--;
      break;

    case '.':
      if ((status & TVC_FRACTION) == 0) {
	fracpart -= digits;
	status |= TVC_FRACTION;
	NEXTCH();
	width--;
	if (digits == 0) {
	  while (width != 0 && ch == '0') {
	    NEXTCH();
	    width--;
	    fracpart++;
	    status |= TVC_SCANZEROS;
	  }
	}
	break;
      }

    default:
      goto BadDigit;
    }
  }

BadDigit:

  if (digits == 0 && (status & TVC_SCANZEROS) == 0)
    goto Failed;

  if ((status & TVC_FRACTION) == 0)
    fracpart -= digits;

  if (imantdigs != 0) {
    if (digits <= LDBL_DIG/2)
      mant.number = imantissa;
    else {
      mant.guard = mant.guard * __fpow10[imantdigs] + imantissa;
      gdigits   += imantdigs;
    }
  }
  if (gdigits != 0)
    mant.guard /= __fpow10[gdigits];

/* In order to ensure that LDBL_MIN is able to be scanned properly
 * it is necessary the normalised decimal mantissa need only a single
 * guarded multiplication to convert it into the required number.
 */
   ASSERT(LDBL_DIG/2 - 1 + LDBL_MIN_10_EXP >= __mpow10);

/* Exponent */
  if (width != 0 && (ch == 'e' || ch == 'E')) {
    NEXTCH();
    width--;
    if (width != 0) {
      if (ch == '-') {
	status |= TVC_EXPNEGATIVE;
	NEXTCH();
	width--;
      } else if (ch == '+') {
	NEXTCH();
	width--;
      }
    }

    expoffset = digits - fracpart - 1;
    if ((status & TVC_EXPNEGATIVE) != 0)
      expoffset = -expoffset;

    while (width != 0 && ch >= '0' && ch <= '9') {
      status |= TVC_EXPONENT;
      if (exponent + expoffset <= LDBL_MAX_10_EXP)
        exponent = exponent * 10 + (ch - '0');
      NEXTCH();
      width--;
    }
    if ((status & TVC_EXPONENT) == 0)
      goto Failed;
    if ((status & TVC_EXPNEGATIVE) != 0)
      exponent = -exponent;
  }

/* Merge mantissa and exponent */
  exponent += gdigits - fracpart;

  if (exponent < 0) {

    while (exponent < __mpow10) {
      __gpow10(__mpow10, &pow10);
      __ggmul(&mant, &mant, &pow10);
      __gguard(&mant);
      exponent -= __mpow10;
    }

    __gpow10(exponent, &pow10);
    Mantissa = __gmul(&mant, &pow10);
  }

  else {

    normexp = exponent + (digits - gdigits) - 1;

/* Magnitude of number is too great */
    if (normexp > LDBL_MAX_10_EXP)
      Mantissa = HUGE_VAL;

/* Exponent is in range or on limit */
    else {
      while (exponent > LDBL_MAX_10_EXP) {
	__gpow10(LDBL_MAX_10_EXP, &pow10);
	__ggmul(&mant, &mant, &pow10);
	__gguard(&mant);
	exponent -= LDBL_MAX_10_EXP;
      }

/* Number is well within range */
      if (normexp < LDBL_MAX_10_EXP) {
	__gpow10(exponent, &pow10);
	Mantissa = __gmul(&mant, &pow10);
      }

/* Number may overflow and is close to the limit of the representation. */
      else {
	__gpow10(gdigits - digits + 1, &pow10);
	__ggmul(&mant, &mant, &pow10);
	__gguard(&mant);
	__gpow10(LDBL_MAX_10_EXP, &pow10);
	Mantissa  = __gmul(&mant, &pow10);
        Mantissa /= flt_radix;
        if (Mantissa <= * (longdouble *) &ldbl_max_radix[0])
	  Mantissa *= flt_radix;
        else
	  Mantissa = HUGE_VAL;
      }
    }
  }

/* Merge sign */
  if ((status & TVC_NEGATIVE) != 0)
    Mantissa = -Mantissa;

/* Generate result */
  *ok = 1;
  switch (fptype) {
  case 1: * VA_ARG(*argp, longdouble *) = Mantissa; break;
  case 2: * VA_ARG(*argp, double *)     = Mantissa; break;
  case 3: * VA_ARG(*argp, float *)      = Mantissa; break;
  }

Failed:
  ungetc(ch, fp);
  return nbytes;
}
