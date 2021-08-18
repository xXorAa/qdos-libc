/*
 *		r e a d d i r
 *
 *	Routine to return the next (UNIX style) directory entry.
 *
 *	NOTE.  It would be more efficient if we did not continually
 *	   open/close the directory.  However, this is done so
 *	   that the directory is not kept open across calls to
 *	   this routine as this more closely emulates the way
 *	   that one works in Unix.
 *
 *	Amendment History
 *	~~~~~~~~~~~~~~~~~
 *	24 Apr 93	DJW   - It was possible to get out of this routine
 *						without closing the directory channel if the
 *						read_qdir() call failed.  This could result in
 *						many channels being left open.
 *						(problem reported by Erik Slagter)
 *					  - Use of 'goto' statements to common up exit paths
 *						removed.  This is done automatically by the C68
 *						peephole optimiser anyway.
 *					  - Changed fs_pos() calls to check return values
 *						rather than _oserr to detect error conditions.
 *
 *	21 Aug 93	DJW   - Removed assumption that open_qdir() sets up the
 *						error codes when QDOS error code returned.
 *
 *	09 Nov 93	DJW   - Slight change due to fact that d_namelen field changed
 *						to d_namlen to bring in line with UNIX standard
 *						(reported by Phil Gaskell)
 *
 *	02 Aug 95	EAJ   - Adds underscore to the wildcard, and makes sure that
 *						the underscore is included in "len".
 *						This is so that the names returned, when the directory
 *						supplied does not include the trailing underscore,
 *						are not prefixed with an underscore !
 *						(Once again, "diff" revealed this problem)
 *						(code reworked by DJW to be more effecient).
 *
 *	12 Jan 96	DJW   - Changed to correctly add terminator after wild-card
 *						(was adding it too late).
 *					  - Corrected error that chopped of first character of name.
 *						(introduced when adding fix for no trailing underscore).
 *						Problem and fix from Thierry Godefrey.
 *					  - Moved check for trailing underscore to opendir() where
 *						it makes more sense for it to be present as it is then
 *						only done once.
 *
 *	20 Jan 96	DJW   - Changed to use new 'dd_namelen' field in 'DIR' structure.
 */

#define __LIBRARY__

#include <qdos.h>
#include <dirent.h>
#include <errno.h>
#include <string.h>

struct dirent * readdir _LIB_F1_ ( DIR *,	dirp)
{
	chanid_t chid;
	struct qdirect qbuf;
	struct dirent *dp;
	char	devwc[MAXNAMELEN+2];
	size_t	len;
	long	reply;

	/*
	 *	Check we have a valid pointer
	 */
	if (dirp == NULL) {
		errno = EBADF;
		return NULL;
	}
	/*
	 *	Open the QDOS directory
	 */
	if((chid = open_qdir(dirp->dd_name)) <= 0) {
		if (chid < 0) {
			_oserr = chid;
			errno = EOSERR;
		}
	return NULL;
	}

	(void) strcpy(devwc, dirp->dd_name);
	len = dirp->dd_namelen;
	devwc[len] = '*';				/* Add wildcard character */
	devwc[len+1] = '\0';			/* Add NULL terminator */

	/*
	 *	Seek to the correct position
	 */
	if ((reply=fs_pos(chid, dirp->dd_loc, (short)0)) < 0 ) {
		_oserr = reply;
		errno = EOSERR;
		(void) io_close (chid);
		return NULL;
	}
	dp = &dirp->dd_buf;
	/*
	 *	Read the next directory entry
	 */
	if((reply=read_qdir(chid, devwc, dp->d_name, &qbuf, 0)) != 1) {
		(void) io_close(chid);
		return NULL;
	}
	/*
	 *	Save the new position
	 */
	dirp->dd_loc = fs_pos(chid,0L,1L);

	/*
	 *	Remove the un-needed parts of the name
	 *	(the parts common to dirp->dd_name
	 */
	(void) strcpy( dp->d_name, &dp->d_name[len]);
	dp->d_namlen = (short)strlen(dp->d_name);
	dp->d_reclen = (short)(DIRSIZ(dp));
	/*
	 * Close the directory
	 */
	(void) io_close(chid);

	return dp;
}

