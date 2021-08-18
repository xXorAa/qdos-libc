/*
 *			s t r t o d
 *
 *	Convert ASCII string to double.
 *
 *	Synopsis:
 *	~~~~~~~~
 *		#include <stdlib.h>
 *		double strtod (const char *nptr, char ** endptr);
 *
 *	Description
 *	~~~~~~~~~~~
 *	The strtod function converts the initial portion of the string pointed
 *	to by 'nptr' to 'double' representation.  First, it decomposes the input
 *	string into threee parts; an initial, possibly empty, sequence of white
 *	space characters (as specified by the 'isspace' function), a subject
 *	sequence resembling a floating point constant; and a final string of one
 *	or more unrecognized characters, including the terminating null character
 *	of the input string.  The it attempts to convert the subject sequence to
 *	a floating point number and return the result.
 *
 *	The expected form of the subject sequence is an optional plus or minus
 *	sign, then a nonempty sequence of digits optionally containing a decimal
 *	point character, then an optional exponent part, but no floating suffix.
 *	The subject sequence is defined as the longest initial subsequence of the
 *	input string, starting with the first non-white-space character, that is
 *	of the expected form.  The subject sequence contains no characters if the
 *	input string is empty or consists entirely of white space, or if the first
 *	non-white-space character is other than a sign, a digit, or a decimal
 *	point character.
 *
 *	If the subject sequence has the expected form, the sequence of characters
 *	starting with the first digit or the decimal point character (whichever
 *	occurs first) is interpreted as  floating point constant according to
 *	the standard rules, and if neither an exponent part or a decimal point
 *	character appears a decimal point is assumed to follow the last character
 *	in the string.	 If the subject sequence begins with a minus sign, the
 *	value resulting from the conversion is negated.  A pointer to the final
 *	string is stored in the object pointed to be 'endptr' is not a null
 *	pointer.
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
 *	The 'strtod' function returns the converted value, if any.	If no
 *	conversion could be performed, zero is returned.  If the correct value is
 *	outside the range of representable values, plus or minus HUGE_VAL is
 *	returned (according to the sign of the value), and the value of the
 *	macro ERANGE is stored in 'errno'.	If the correct value would cause
 *	underflow, zero is returned and the value of the macro ERANGE is stored
 *	in 'errno'.
 *
 *
 *	AMENDMENT HISTORY
 *	~~~~~~~~~~~~~~~~~
 *	21 Jun 94	DJW   - Casts added to correctly handle characters with
 *						internal values above 127.
 *						(Problem report and fix from Erling Jacobsen)
 *
 *	02 jan 95	DJW   - Added missing 'const' qualifier to function declaration
 *
 *	03 Mar 95	DJW   - Fixed to return correct values under error conditions
 *						as defined by ANSI.
 *					  - Parameters now use _LIB_F2_ macro
 */

#define __LIBRARY__

#include <ctype.h>
#include <errno.h>
#include <math.h>
#include <stddef.h>
#include <stdlib.h>


/*	NOTE.
 *		The two routines that are in the assembler support file
 *		have prototypes defined in the <stdlib.h> file
 */

double strtod _LIB_F2_( const char *,	str, \
						char **,		endp)
{
	const char * s = str;
	int mdigit = 0; 		/* set if mantissa character digit */
	int point = 0;			/* set if decimal point found */
	int sign = 0;			/* set if mantissa negative */
	int esign = 0;			/* set if exponent negative */
	int decexp = 0; 		/* decimal exponent */
	double value = 0;		/* accumulated value - actually */
							/* a 64-bit integer */

	/*
	 *	Skip any leading white space
	 */
	while(isspace((unsigned char)*s))
		s++;

	/*
	 *	Handle leading sign
	 */
	switch (*s)
	{
	case '-':
			sign++;
			/* FALLTHRU */
	case '+':
			s++;
			/* FALLTHRU */
	default:
			break;
	}

	/*
	 * Start by getting any values before the exponent
	 */
	for(; ; ++s)
	{
		if(isdigit((unsigned char)*s))
		{
			mdigit++;
			if(_mul10add(&value, *s - '0'))
				++decexp;
			if(point)
				--decexp;
		}
		else if(*s == '.')
		{
			if (point)
				break;
			point++;
		}
		else
		{
			break;
		}
	}
	/*
	 * Then get the exponent value (if any)
	 * (as long as a initial numeric part found)
	 */
	if(mdigit && (*s == 'e' || *s == 'E'))
	{
		int eacc = 0;				/* exponent accumulator */

		switch (*++s)
		{
		case '-':
				esign++;
				/* FALLTHRU */
		case '+':
				s++;
				/* FALLTHRU */
		default:
				break;
		}

		while(isdigit((unsigned char)*s))
		{
			if(eacc < 1000)
				eacc = eacc * 10 + (*s - '0');
			s++;
		}

		if(esign)
			decexp -= eacc;
		else
			decexp += eacc;
	}

	/*
	 *	Set up the end-pointer (if desired).
	 *	If no conversion was done, then
	 *	this points to original string
	 */
	if(endp != (char **)NULL)
	{
		if (mdigit)
			*endp = (char *)s;
		else
			*endp = (char *)str;
	}

	/*
	* Now do some range checks
	*/
	if(decexp > 350)			   /* outrageously large */
	{
		if (sign == 0) {
			value = HUGE_VAL;
		} else {
			value = -HUGE_VAL;
		}
		errno = ERANGE;
		return (value);
	}
	else if(decexp < -350)		   /* outrageously small */
	{
		value = 0.0;
		errno = ERANGE;
		return value;
	}

	/*
	 *	If everything was OK simply
	 *	return the normalised number
	 */
	return _adjust(&value, decexp, sign);
}
