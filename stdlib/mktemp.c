/*
 *				m k t e m p
 *
 * Routine to make a temporary file name.
 * It expects the template to be of the form "filenameXXXXXX".
 * The X's will be replaced by a character string that can be
 * used to create a unique filename.  A maximum of 26 filenames
 * can be got for the same process via this routine.
 *
 * AMENDMENT HISTORY
 * ~~~~~~~~~~~~~~~~~
 *	03 Jul 92	EJ	  - mktemp alters the given name without expanding it!
 *						otherwise crashes may occur in programs that use it
 *						like this: char *p="nameXXXXXX"; p=mktemp(p);
 *						which is the correct way to use it.
 *
 *	22 Aug 94	DJW   - Removed unecessary calls to _super() and _user()
 *						calls as there is no reason to need supervisor mode.
 *					  - Changed algorithm to have random number in bottom part
 *						of pattern as this means that all files for the same
 *						process have the top part the same in unix style.
 *					  - Removed call to mt_inf().  Used global '_Jobid'
 *						variable instead.
 *
 *	15 Feb 97	DJW   - Changed algorithm to conform to the normal Unix
 *						convention of using a letter followed by a the
 *						process ID.  We actually use the job tag as this
 *						is less likely to clash due to re-use but the
 *						principle is the same.
 */

#define __LIBRARY__

#include <stdlib.h>
#include <string.h>
#include <qdos.h>

#ifdef TESTING

/*
 *	Test of mktemp() call
 */

#include <stdio.h>

int main(int argc, char * argv[])
{

	char	fnam[36] = "ram1_gs";
	char	*p;
	short	i;
	FILE *	fp[10];

	for (i=0 ; i<10 ; i++)
	{
		strcpy(fnam+7, "XXXXXX");
		p = mktemp(fnam);
		if ( p == NULL)
		{
			printf("mktemp() returned NULL\n");
		} else {
			printf ("open %s %p\n", p, fopen(p, "w"));
		}
	}
}
#endif /* TESTING */


char *mktemp _LIB_F1_(char *,	mask)
{
	int 	count;
	jobid_t pid;
	char *p, *px;
	chanid_t	chid;

	/*
	 *	Find start of XXX part of mask.  For safety reasons we
	 *	do not assume that there are exactly 6 'X's as there
	 *	really should be.
	 */
	for (px = mask + strlen(mask) - 6 ; *px ; px++)
	{
		if (*px == 'X')
		{
			break;
		}
	}
	if (*px != 'X')
	{
		return NULL;
	}

	/*
	 *	Now work through the filenames.
	 *	If the file already exists, then
	 *	try the next one.
	 */
	for (count = 0 ; count < 26 ; count++)
	{
		pid = (unsigned long)_Jobid >> 16;	   /* use Job Tag */
		*px = (char)('a' + count);
		for (p = mask + strlen(mask) ; --p > px ; )
		{
			*p = "0123456789ABCDEF"[(unsigned long)pid & 0x0F];
			pid >>= 4;
		}
		/*
		 *	Check file does not already exist
		 */
		switch (chid = io_open(mask,OLD_SHARE))
		{
			case 0:
					(void)io_close (chid);
					/* FALL THRU */
			case ERR_IU:
					continue;
			default:
					return mask;
		}
	}
	return (NULL);
}
