/*
 *			p o p e n
 *
 * Unix compatible routine to open a pipe between jobs,
 * either for read or write.
 *
 *	Amendment History
 *	~~~~~~~~~~~~~~~~~
 *	22 Oct 92	DJW   - Added code to set top bit of channel ID for the
 *						end of the pipe to be handled by the user.
 *
 *	11 Apr 94	EAJ   - The above changed so owner is changed. Also,
 *						_Chkufb is called again, after forkl().
 *
 *	04 Sep 94	DJW   - Modified to use the argunpack() routine for parsing
 *						the command line into arguments.  This makes it
 *						consistent with the start-up doce, which now also
 *						uses argunpack(), and with _forkexec() which uses
 *						the complementary routine argpack().
 *
 *	02 Jan 95	DJW   -Added missing 'const; qualifiers to function declaration
 */

#define __LIBRARY__

#include <qdos.h>
#include <stdio.h>
#include <unistd.h>
#include <fcntl.h>
#include <errno.h>
#include <stdlib.h>

FILE *popen( cname, mode)
  const char *cname;
  const char *mode;
{
	FILE *fp;
	int fds[4]; 								/* File descriptors for pipes */
	int fdparent, fdchild;
	struct UFB *uptr;
	jobid_t jobid;
	char ** argv = NULL;
	int 	argc = 0;

	if (pipe(&fds[1]))							/* Open pipe */
		return (FILE *)NULL;					/* ... and exit if fails */

	fds[0] = 3; 								/* Number of channels to pass to job */
	if (*mode == 'r') {
		fdparent = fds[1];						/* Copy the read fd */
		fdchild  = fds[2];						/* Save the write fd */
		fds[1] = -1;
	} else if (*mode == 'w') {
		fdparent = fds[2];						/* Copy the write fd */
		fdchild  = fds[1];						/* Save the read fd */
		fds[2] = -1;
	} else {
		errno = EINVAL;
		(void) close( fds[1] );
		(void) close( fds[2] );
		return (NULL);
	}
	fds[3] = fds[2];							/* Move stdout to last channel */
	fds[2] = -1L;								/* always pass our stderr channel */

	uptr = _Chkufb(fdparent);					/* Get file control area */
	uptr->ufbfh1 = fdchild; 					/* Store fd for child end */

	if ((fp=fdopen(fdparent,mode))==NULL) {          /* Open up level 2 for parent */
		(void) close (fdparent);
		(void) close (fdchild);
		return (FILE *)NULL;
	}

	/*
	 *	We have open up a pipe.  Start the child
	 *	job passing it the file descriptor of one
	 *	end of the pipe as stdin/stdout depending
	 *	on mode required.
	 *
	 *	Now parse command into program name and args.
	 */

	if (argunpack(cname, &argv, &argc, NULL) == -1) {
		return NULL;
	}
	jobid = forkv( argv[0], fds, argv );

	argfree( &argv );

	/*
	 *	Do _Chkufb again, as table of ufb's may have moved ?
	 */
	if(( (uptr=_Chkufb(fdparent))->ufbjob = jobid) == -1L) {
		(void) fclose (fp); 				/* close parent resources */
		(void) close (fdchild); 			/* close child resources */
		return (FILE *)NULL;				/* return with error */
	}
	(_Chkufb(fdchild))->ufbflg = 0; 		/* Channel to be closed by child */
	return fp;
}
