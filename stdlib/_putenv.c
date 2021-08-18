/*
 *						p u t e n v
 *
 *	putenv - Copy string of the form name=value to the enviroment and adjust the
 *			 environ vector to point to the copied string.
 *
 *			As a special non-standard extension, calling putenv() giving just
 *			the variable name without the following equals sign or the new
 *			value will remove the variable completely from the environemnt.
 *
 *	V 1.00 - 05.01.92 - DFN - Initial version
 *
 *	V 1.01 - 01.02.92 - DJW - _rmvenv routine merged into putenv as it appears
 *							  to be unecessary to keep it separate.
 *							  Some sanity checks on parameters added.
 *							  Option for delete only added.
 *
 *	V 1.02 - 02.07.92 - EJ (Erling Jacobsen) bugfix
 *
 *	V 1.03 - 17/07/92 - R.Kettlewell - numerous bugs removed; some
 *							strange decisions about which function to
 *							call, also (e.g. strpbrk vs strchr;
 *							strncpy vs strcpy) changed to more
 *							logical versions.
 *
 *							Support functions renamed.
 *
 *	V 1.04 - 24.09.92 - Dave Walker
 *						Replaced call to local routine 'env_buildvectors' by
 *						call to envunpk() in standard C library, and then
 *						removed associated code.
 *
 *	25 Feb 95	DJW   - Amended to use _LIB_Fn_ macros for parameters
 */

#define __LIBRARY__

#include <stdlib.h>
#include <qdos.h>
#include <string.h>
#include <unistd.h>

#ifdef __STDC__
#define _P_(params) params
#else
#define _P_(params) ()
#endif

static int env_length _P_((void));

#undef _P_


int putenv _LIB_F1_(char *,  var)
{
	size_t len, n;
	int num;
	char *p;
	char *env = _VENV;

	/*
	 * First do some sanity checks on the parameters
	 *
	 * a) Parameter must not be NULL
	 * b) Parameter can only be zero length string if
	 *	  the environment is not already set up.
	 */

	if(!var)
		return -1;

	if(env) {
		if(!*var)
			return -1;
		else {
			/*
			 *			_ r m v e n v
			 *
			 *	As long this is not the initial set-up, we start by
			 *	trying to delete environment variable (of the form
			 *	'name' or 'name=value') from the enviroment.
			 */
			char *q;

			if ((p = strchr(var, '=')) != NULL)
				*p = '\0';					/* if "name=var", truncate */
			q = getenv(var);
			if(p)
				*p = '=';					/* restore = character */
			if (q) {
				char *r, *s;
				/*
				 * name found in evironment
				 *
				 * RK.	There was a rather pernicious bug here. Someone
				 * beleived that the expression
				 *
				 *	(char *)((long)q-strlen(var)-1)
				 *
				 * ... was the start of the environment variable. Two
				 * points manifest themselves:-
				 *
				 *	1) It isn't, unless there is no '=' part. If the
				 *	   expression had been evaluate before "*p = '=';"
				 *	   above, then things would be different.
				 *
				 *	2) The expression is an abominable piece of C. There
				 *	   is NO NEED to turn pointers into longs to perform
				 *	   arithmetic on them, because you can add or subtract
				 *	   integers to/from pointers, and subtract one pointer
				 *	   from another (giving some integer type as a result.)
				 *
				 *	   If the expression gave the correct value, a better
				 *	   way of writing it would be simply
				 *
				 *			q-strlen(var)-1
				 */
				r = q-1;
				/*
				 * *r == '=' if environment is well formed
				 * Now find start: but don't fall off bottom of environment!
				 */
				while(r != env && r[-1] != '\0')
					--r;
				/*
				 * Now, *r == first character of variable to delete
				 * Find next variable in trad. fashion
				 */
				s = r + strlen(r) + 1;
				/*
				 * Now, *s == first character of next variable,
				 *	 OR *s == '\0' if r is last
				 * Length required is from s up to and including terminating null
				 *	= total length of environment - offset of s from env
				 *	= env_length() + 1 - (s - env)
				 *	= env_length() + 1 + env - s
				 */
				len = env_length() + 1 + (env - s);
				/*
				 * There was a cast (size_t)len in the function call. Why!?
				 * ... len is ALREADY of type size_t.
				 */
				(void) memmove(r, s, len);	/* move variable */
			} else if(!p)					/* were we trying to delete only ? */
				return -1;					/* ... if so not found is an error */
			if(!p)							/* are we merely trying to delete variable */
				return -2;					/* ... if so special return value if OK */
		}
	} 

	/*
	 *			_ s e t e n v
	 *
	 *	It is now time to add the new variable to the environment
	 */

	/* Get number of variables (was _envnum() */
	num = 0;
	if(environ != NULL)
		while(environ[num] != NULL)
			++num;

	len = env_length(); 	/* get length of environment, less terminator */
	n = strlen(var) + 1;	/* length of new variable + terminator */

	/*
	 * Note: realloc(NULL, size) is the same as malloc(size) in C68 (and ANSI)
	 */
	if ((env = realloc(_VENV, len + n + 1)) == NULL) { /* expand enviroment */
		return (-1);
	} else {
		_VENV = env;
	}

	(void) strcpy(env + len , var); 		/* copy new variable */
	env[len+n] = '\0';						/* mark end of enviroment */
	return (envunpk(env));					/* exit rebuilding table */
}

/*
 *				_ e n v _ l e n g t h
 *
 * Internal function to return the length of the enviroment
 * string (IMPORTANT: final \0 not counted).
 *
 */

static int env_length _LIB_F0_(void)
{
	char *p;

	p = _VENV;
	if (_VENV != NULL) {
		for (; *p != '\0'; p += strlen(p) + 1)
			;
	}

	return p - _VENV;
}
