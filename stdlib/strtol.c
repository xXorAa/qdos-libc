/*
 *		s t r t o l
 *
 * Routine to use as base for all atoi, atol etc routines.
 * Used by scanf etc.
 *
 *	Synopsis:
 *	~~~~~~~~
 *		#include <stdlib.h>
 *		long int strtol (const char *nptr, char ** endptr, int base);
 *
 *	Description
 *	~~~~~~~~~~~
 *	The strtol function converts the initial portion of the string pointed
 *	to by 'nptr' to 'integer' representation.  First, it decomposes the input
 *	string into three parts; an initial, possibly empty, sequence of white
 *	space characters (as specified by the 'isspace' function), a subject
 *	sequence resembling an integer in some radix determined by the value of
 *	'base'; and a final string of one or more unrecognized characters,
 *	including the terminating null character of the input string.  Then it
 *	attempts to convert the subject sequence to an long integer and return
 *	the result.
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
 *	The 'strtol' function returns the converted value, if any.	If no
 *	conversion could be performed, zero is returned.  If the correct value is
 *	outside the range of representable values, LONG_MAX or LONG_MIN is returned
 *	(according to the sign of the value), and the value of the macro ERANGE is
 *	stored in 'errno'.
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
 *	05 Mar 95	DJW   - Changed to use _LIB_F3_ macro for parameters
 *					  - Changed to use strtoul() as a support routine
 */

#define __LIBRARY__

#include <stdlib.h>
#include <ctype.h>
#include <errno.h>
#include <limits.h>


long strtol _LIB_F3_(const char *,	np, \
					 char **,		endptr, \
					 int,			base)
{
	int errno_old;
	const char * nptr;
	unsigned long result;

	/*
	 *	Skip any white space
	 */
	for(nptr = np ; isspace((unsigned char)*nptr) ; nptr++) {
		;
	}
    errno_old = errno;
    errno = 0;
	result = strtoul (np, endptr, base);

	if (*nptr == '-') {
		if (errno || result <= LONG_MAX) {
			errno = ERANGE;
			return (LONG_MIN);
		}
	} else {
		if (LONG_MAX < result) {
			errno = ERANGE;
			return (LONG_MAX);
		}
	}
    errno = errno_old;
	return ((long)result);
}

