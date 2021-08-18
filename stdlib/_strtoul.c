/*
 *		s t r t o u l
 *
 *	Converts a numeric string, in various bases, to an unsigned long.
 *	This routine is also used as a support routine by the atoi(),
 *	atol() and strtol() routines.
 *
 *	Synopsis:
 *	~~~~~~~~
 *		#include <stdlib.h>
 *		unsigned long int strtoul (const char *nptr, char ** endptr, int base);
 *
 *	Description
 *	~~~~~~~~~~~
 *	The strtoul function converts the initial portion of the string pointed
 *	to by 'nptr' to 'unsigned long int' representation.  First, it decomposes
 *	the input string into three parts; an initial, possibly empty, sequence
 *	of white space characters (as specified by the 'isspace' function), a
 *	subject sequence resembling an unsigned integer in some radix determined
 *	by the value of 'base'; and a final string of one or more unrecognized
 *	characters, including the terminating null character of the input string.
 *	Then it attempts to convert the subject sequence to an unsigned long
 *	integer and return the result.
 *
 *	If the value of 'base' is zero. the expected from of the subject sequence
 *	is that of an integer constant, optionally preceded by a  plus or minus
 *	sign, but not including an integer suffix.	If the value of 'base' is
 *	between 2 and 36, the expected form of the subject sequence is a sequence
 *	of letters and digits representing an integer with the radix specfied by
 *	'base', optionally preceeded by a plus or minus sign, but not including
 *	an integer suffix.	The letters from a (or A) through z (or Z) are ascribed
 *	the values 10 to 35;  only letters whose ascribed values are less than
 *	that of 'base' are permitted.  if the value of 'base' is 16, the characters
 *	0x or 0X may optionally precede the sequence of letters and digits,
 *	following the sign if present.
 *
 *	The subject sequence is defined as the longest initial subsequence of the
 *	input string, starting with the first non-white-space character, that is of
 *	the expected form.	The subject sequence contains no characters if the
 *	input string is empty or consists entirely of white space, or if the first
 *	non-white-space character is other than a sign or a permissable letter
 *	or digit.
 *
 *	If the subject sequence has the expected form and the value of 'base' is
 *	zero, the sequence of characters starting with the first digit is
 *	interpreted as an integer constant according to the standard rules.  If the
 *	subject sequence has the expected from and the value of 'base' is between
 *	2 and 36, it is used as the base for conversion ascribing to each letter
 *	its value as given above.  if the subject sequence begins with a minus
 *	sign, the value resulting from the conversion is negated.  A pointer to
 *	the final string is stored in the object pointed to be 'endptr', providing
 *	that 'endptr' is not a null pointer.
 *
 *	In other than the "C" locale, additional implementation defined subject
 *	sequence forms may be accepted.
 *
 *	if the subject sequence is empty or does not have the expected form, no
 *	conversion is performed;  the value of 'nptr' is stored in the object
 *	pointed to by 'endptr', provided that 'endptr' is not a null pointer.
 *
 *	Returns
 *	~~~~~~~
 *	The 'strtoul' function returns the converted value, if any.	If no
 *	conversion could be performed, zero is returned.  If the correct value is
 *	outside the range of representable values, ULONG_MAX or is returned and
 *	the value of the macro ERANGE is stored in 'errno'.
 *
 *
 *	AMENDMENT HISTORY
 *	~~~~~~~~~~~~~~~~~
 *	21 Jun 94	DJW   - Casts added to correctly handle characters with
 *						internal values above 127.
 *						(Problem report and fix from Erling Jacobsen)
 *
 *	02 Jan 95	DJW   - Added missing 'const' qualifier to function declaration
 *
 *	05 Mar 95	DJW   - Now use the _LIB_F3_ macro for parameters
 *					  - Returns the correct value in 'eptr' if no conversion
 *						is performed.
 *					  - Use _BASEMUL macro to avoid long multiplies on 68K.
 */

#define __LIBRARY__

#include <ctype.h>
#include <errno.h>
#include <limits.h>
#include <stdlib.h>

/* defines to avoid long muls on a lowly 68k */
#ifdef MC68000
#define _TEN_MUL(X) ((((X) << 2) + (X)) << 1)
#define _BASEMUL(B, X) \
	(((B) == 10) ? _TEN_MUL((X)) : (((B) == 16) ? ((X) << 4) : (((B) == 8) ? \
									((X) << 3) : ((B)*(X))	)))
#else
#define _BASEMUL(B, X)	 B * X
#endif /* MC68000 */

unsigned long int strtoul _LIB_F3_(const char *,  np, \
								   char **, 	  endptr, \
								   int, 		  base)
{
  const char * nptr;
  int c;
  unsigned long int result = 0L;
  unsigned long int limit;
  int negative = 0;
  int overflow = 0;
  int saw_a_digit = 0;				/* it's not a number without a digit */


  /*
   *  Handle leading white space
   */
  for (nptr = np ; (c = (int)(unsigned char)*nptr) != 0 ; nptr++) {
	if ( ! isspace(c)) {
		break;
	}
  }

  /*
   *  Handle sign
   */
  switch (c) {
  case '-':
		negative++;
		/* FALLTHRU */
  case '+' :
		nptr++;
		/* FALLTHRU */
  default:
		break;
  }

  /*
   *	Handle base determination if unknown
   */
  if (base == 0) {
	base = 10;
	if (*nptr == '0') {
		nptr++;
		if ((c = (int)(unsigned char)*nptr) == 'x' || c == 'X') {
			base = 16;
			nptr++;
		} else {
			base = 8;
			saw_a_digit++;
		}
	}
  } else if (base == 16 && *nptr == '0') { /* discard 0x/0X prefix if hex */
	++nptr;
	if (((c = (int)(unsigned char)*nptr) == 'x') || c == 'X') {
		++nptr;
	} else {
		saw_a_digit++;
	}
  }

  limit = (unsigned long)ULONG_MAX / (unsigned long)base;		/* ensure no overflow */

  --nptr;										/* convert the number */
  while ((c = (int)(unsigned char)*++nptr) != 0) {
	if (isdigit(c)) {
		c -= '0';
	} else {
		c -= isupper(c) ? ('A' - 10) : ('a' - 10);
	}
	if (c < 0 || c >= base) {
		break;
	}
	saw_a_digit++;
	if (result > limit) {
		overflow++;
	}
	if (!overflow) {
		result = _BASEMUL(base,result);
		if (c > (unsigned long)ULONG_MAX - result) {
			overflow++;
		} else {
			result += c;
		}
	}
  }

  if (overflow) {
	errno = ERANGE;
	result = (unsigned long)ULONG_MAX;
  } else {
	/* BIZARRE, but ANSI says we should do this! */
	if (negative) {
		result = 0L - result;
	}
  }

  if (endptr != (char **) NULL) {   /* record good final pointer */
	if (saw_a_digit) {
		*endptr = (char *)nptr;
	} else {
		*endptr = (char *)np;
	}
  }
  return result;
}

