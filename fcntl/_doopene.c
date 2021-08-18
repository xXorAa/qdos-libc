/*
 *				_ d o _ o p e n e
 *
 * Routine to search more than just the default
 * directory, if parameter set ok.
 *
 *	It is used by both the opene() and fopene()
 *	call, and exploits the fact that
 *		a) sizeof(int) == sizeof(char *)
 *		   (for 2nd parameter)
 *		b) sizeof(int) == sizeof(FILE *)
 *		   (for return value)
 *		c) a successful open returns +ve reply
 *
 *	Look at 3bits in paths : top bits first
 *	followed by next 3, followed by bottom 3.
 *		If 3bits == 4 - Search dest. directory
 *		If 3bits == 3 - search prog directory
 *						and then data directory
 *		If 3bits == 2 - search program directory
 *		If 3bits == 1 - search data directory
 *						then program directory
 *		If 3bits == 0 - search data directory
 *
 *	AMENDMENT HISTORY
 *	~~~~~~~~~~~~~~~~~
 *	01 Feb 93 - Inserted line to exlicitly set error code under 'fall thru'
 *				condition (as reported by Dirk Steinkopf).
 *			  - Removed FINISHED label - let C68 optimiser phase do work
 *				as it is likely to do a better job than humans!
 */

#define __LIBRARY__

#include <qdos.h>
#include <unistd.h>
#include <errno.h>

#ifdef __STDC__
#define _P_(params) params
#else
#define _P_(params) ()
#endif
static	long open_in_directory _P_((char *, char *,long, long (*)()));
#undef _P_

long _do_opene _LIB_F4_ ( char *,	name, \
						  long, 	mode, \
						  int,		paths, \
						  long, 	(*function)(char *, long))
{
	int   fnreply;
	int   tpath;
	int   devtype;
	short i;
	char  cwd[MAXNAMELEN+1];
	char  cpd[MAXNAMELEN+1];
	char  cdd[MAXNAMELEN+1];

	/*
	 *	First check that we have been given search criteria
	 *	and that path is not lread absolute as either of these
	 *	mean we just do a standard open
	 */
	if ( (paths &= 0777)					/* Check search criteria set */
	&&	(isdevice( name, &devtype)) ) {     /* ... and path not already set */
		return (int)(*function)( name, mode);
	}
	/*
	 *	Analyse paths and do requisite opens
	 */
	for( i = 2; i >= 0; --i)
	{
		if(!(tpath = ((unsigned)((unsigned)paths >> (unsigned)(i*3)) & 7U)))   /* Get the search paths in order */
		{
			continue;							/* If zero don't search */
		}
		/*
		 *	See if start with destination directory
		 */
		if (tpath == 4)
		{
			if ((fnreply = open_in_directory (name, getcdd(cdd,MAXNAMELEN),
											 mode, function)) != 0)
			{
				return fnreply;
			}
		}
		/*
		 *	See if start with program directory
		 */
		if ((unsigned)tpath & 2U)
		{
			if ((fnreply = open_in_directory (name, getcpd(cpd,MAXNAMELEN),
											  mode, function)) != 0)
			{
				return fnreply;
			}
		}
		/*
		 *	See if start with data directory
		 */
		if ((unsigned)tpath & 1U)
		{
			if ((fnreply = open_in_directory (name, getcwd(cwd,MAXNAMELEN),
											  mode, function)) != 0)
			{
				return fnreply;
			}
		}
		/*
		 *	followed by program directory ?
		 */
		if (tpath == 1)
		{
			if ((fnreply = open_in_directory (name, getcpd(cpd,MAXNAMELEN), 
												mode, function)) != 0)
			{
				return fnreply;
			}
		}
	}	/* end of for loop */
	/*
	 *	All attempts have failed if we get here
	 */
	_oserr = ERR_NF;
	errno = EOSERR;
	return -1;
}


/*
 *	Local routine to attempt to open a directory in a specified
 *	directory.	 Returns 0 if not found, and reply for user otherwise
 */
static
long open_in_directory (name, directory, mode, function)
char *name;
char *directory;
long mode;
long (*function)(char *, long);
{
	char tempname[MAXNAMELEN+1];
	int fnreply;

	if(_qlmknam( tempname, directory, name, (int)sizeof(tempname)-1) < 0) {
		return -1;
	}
	if ( ((fnreply = (*function)( tempname, mode)) > 0) 
	||	 (_oserr != ERR_NF) )
	{
		return (fnreply);
	}
	return 0;
}
