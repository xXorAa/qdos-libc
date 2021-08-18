/*
 *	s y s t e m
 *
 * simple system() function for C68.
 * (c) 1992 Richard Kettlewell
 *
 *	Amendment History
 *	~~~~~~~~~~~~~~~~~
 *	24 Sep 92	DJW   - Amended listing of environment variables to use
 *						global 'environ' variable which is both more
 *						protable and more efficient.
 *
 *	20 Feb 94	DJW   - Removed assumption about how the DATA_USE and
 *						PROG_USE information is stored by using the library
 *						routines getcwd() and getcpd() instead.
 *
 *	15 Apr 94	EAJ   - cast to unsigned char before using ctype macros !
 *
 *	23 Apr 94	EAJ   - parse commandline in a way similar to the code in
 *						_cmdparse(), so the use of "" or '' or \ is allowed
 *						and processed correctly. See _cmdparse() and _frkex()
 *						which also have been updated to process these features
 *						correctly.
 *
 *	03 Sep 94	DJW   - Switched to using the new argunpack() routine to
 *						parse the command line.  This is the same code that
 *						is used by the start-up code, and is complimentary
 *						to the argpack() routine now used by _forkexec().
 *					  - Removed the tryfile() and findfile() local routines.
 *						We can depend on the forkvp()/execvp() to do this
 *						search so why duplicate code?
 *
 *	21 Dec 94	EAJ   - Returns immediately with OK if command line empty.
 *
 *	02 Jan 95	DJW   - Added missing 'const' qualifer to function declaration
 *
 *	25 Oct 96	DJW   - Added support for multiple commands seperated by
 *						the semicolon character.
 *					  - Ensured that if the CD or CPD built in instructions
 *						are used that they are set back before exiting
 *						back to the user.
 *						(the same should really be done for SET as well,
 *						 but it is a lot of effort for little gain)
 */

#include <stdio.h>
#include <errno.h>
#include <stdlib.h>
#include <qdos.h>
#include <string.h>
#include <unistd.h>


/*
 * List of system commands. Keep in alphabetical order (i.e. all same case)
 * so that if there are very many of these, they may be sought using a
 * binary search without re-writing the switch statement.
 */
static char *system_commands[] = {
	"cd",
	"cpd",
	"set"
};

/* Numerical constants in same order as system commands, with SYS_EXEC
 * one beyond end of list */
enum builtin {
	SYS_CD,
	SYS_CPD,
	SYS_SET,
	SYS_EXEC
};

/*
 *	Internal routine to execute a command.
 *	A & symbol at the end of the command means, concurrent execution.
 */
static
int do_command (const char *s)
{
	enum builtin command;
	char dirbuf[FILENAME_MAX];
	int conc;
	int response;
	int argc;
	char **argv, *arg1;

	response = 0;		/* preset response as good */

	argv = NULL;
	if (argunpack (s, &argv, &argc, NULL) < 0)
	{
		return -1;
	}

	/*
	 *	If command line empty then return good reply.
	 */
	if (argc == 0)
	{
		return response;
	}

	/*
	 *	Check if & used to indicate backgound task
	 */
	conc = !strcmp("&",argv[argc-1]);
	if (conc)
	{
		if (--argc == 0 )
		{
			argfree (&argv);
			return response;
		}
		free (argv[argc]);
		argv[argc] = NULL;
	}

	/*
	 *	See if builtin command
	 */
	for(command = SYS_CD ; command < SYS_EXEC; command++)
	{
		if(!stricmp(argv[0], system_commands[command]))
		{
			break;
		}
	}

	arg1 = argv[1]; 	/* preset pointer to first argument */
	switch(command)
	{
		case SYS_CD:
			/* CD arg modifies the data default
			 * CD on its own prints the data default
			 */
			if (argc > 1)
			{
				response = chdir(arg1);
			}
			else
			{
				(void) puts(getcwd(dirbuf,sizeof(dirbuf)));
			}
			break;

		case SYS_CPD:
			/* CPD works like CD but on program default */
			if( argc > 1)
			{
				response = chpdir(arg1);
			}
			else
			{
				(void) puts(getcpd(dirbuf,sizeof(dirbuf)));
			}
			break;

		case SYS_SET:
			/* SET <name>=<definition> calls getenv()
			 * SET <name> just prints variable
			 * SET lists all environment variables
			 */
			if (argc == 1)
			{
				if(environ == NULL)
				{
					response = ERR_NI;
				}
				else
				{
					char **ptrptr;
					for(ptrptr=environ ; *ptrptr ; ptrptr++)
					{
						(void) puts(*ptrptr);
					}
				}
			}
			else if(strchr(arg1, '=') == NULL)
			{
				char *ptr;
				if ((ptr = getenv(arg1)) == NULL)
				{
					ptr = "\n";
				}
				(void)puts(ptr);
			}
			else
			{
				response = putenv(arg1) ? ERR_BP : 0;
			}
			break;

		case SYS_EXEC:
			/*
			 *	Non-system command
			 */
			if(conc)
			{
				response = forkvp( argv[0], NULL, argv);
			}
			else
			{
				response = execvp( argv[0], (int *)-1, argv);
			}
			if (response == EOSERR)
			{
				response = _oserr;
			}
			break;

		default:
			/*
			 *	Something's gone wrong
			 */
			response = ERR_BN;
			break;
	}
	argfree (&argv);		/* release memory associated with argv vector */
	return response;
}

/*
 *	Execute a command.
 *
 *	If s == NULL, return 0 for no command processor,
 *						 1 for command processor.
 *	If s != NULL, execute it as a command.
 *
 *	A & symbol at the end of the command means, concurrent execution.
 *	A ; symbol seperates multiple commands
 */
int system (const char *s)
{
	int response;
	char origcd[FILENAME_MAX];		/* original current directory */
	char origcpd[FILENAME_MAX]; 	/* original program working directory */
	char *nextcmd;					/* next command (NULL if none) */
	char *thiscmd;					/* this command */

	response = 0;		/* preset response as good */

	/*
	 *	If the parameter is NULL, then return a value
	 *	of 1 to say that command processor exists
	 */
	if(s == NULL)
	{
		return 1;
	}

	/*
	 *	Get directory settings on entry
	 */
	(void) getcwd (origcd, sizeof(origcd));
	(void) getcpd (origcpd, sizeof(origcpd));

	for (response=0, thiscmd = (char *) s ;
				response == 0 && thiscmd != NULL && *thiscmd ; )
	{
		/*
		 *	Search for command separator character.
		 *	If found, then change to NULL character.
		 */
		if ((nextcmd = strchr(thiscmd,';')) != NULL)
		{
			*nextcmd = '\0';
		}

		response = do_command(thiscmd);

		/*
		 *	If there was a command separator,
		 *	restore separator character and
		 *	get ready to do next command.
		 */
		if (nextcmd != NULL)
		{
			*nextcmd++ = ';';
		}
		thiscmd = nextcmd;
	}
	/*
	 *	Restore directory settings to
	 *	values as they were on entry.
	 */
	(void) chdir (origcd);
	(void) chpdir (origcpd);
	return response;
}
