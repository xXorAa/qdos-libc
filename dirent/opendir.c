/*
 *			o p e n d i r
 *
 *	Unix compatible routione to open a directory
 *	in a fil;e system independent manner,.
 *
 *	AMENDMENT HISTORY
 *	~~~~~~~~~~~~~~~~~
 *	21 Aug 93	DJW   - Removed assumption that open_qdir() sets up the
 *						error codes when QDOS error code returned.
 *					  - Amended setting up of inode field to try and give
 *						more chance of it being unique.
 *
 *	12 Jan 96	DJW   - Added check that underscore is always present in
 *						the directory name used.
 *					  - Fixed problem with "." and "./" used as name.
 *					  - Improved algorithm for getting stored directory name.
 *
 *	20 Jan 96	DJW   - Added set up of the new 'dd_namelen' field added to
 *						the 'DIR' structure to improve readdir() effeciency.
 *					  - Reworked the code for the special sequences that are
 *						used to indicate the current directory to be more
 *						effecient.
 *
 *	20 Mar 96	DJW   - Corrected problem where 'dd_namelen' field was not
 *						being set up completely for paths that were not
 *						fully specified.
 */

#define __LIBRARY__

#include <qdos.h>
#include <dirent.h>
#include <errno.h>
#include <string.h>
#include <stdlib.h>
#include <unistd.h>

DIR * opendir _LIB_F1_ (char *,  name)
{
	DIR *dirp;
	char * ptr;
	char   ch;
	chanid_t ret;
	struct qdirect header;

	/*
	 *	Start by checking the length of the
	 *	name is within bounds
	 */
	if(strlen(name) > MAXNAMELEN) {
		errno = ENAMETOOLONG;
		return NULL;
	}
	/*
	 *	Get space for directory control block
	 */
	if(!(dirp = (DIR *) malloc(sizeof(DIR)))) {
		return NULL;
	}
	dirp->dd_loc = 0L;
	/*
	 *	Cope with the special names that would be
	 *	used to indicate the current directory on
	 *	various operating systems. i.e.
	 *		"."
	 *		"._"
	 *		"./"
	 *		".\"
	 *	For all these we simply set the name to
	 *	a zero length string which will later be
	 *	converted to the current data directory.
	 */
	switch (name[0]) {
		case '.' :
				switch (name[1]) {
					case '_':		/* QDOS directory seperator */
					case '/':		/* UNIX directory seperator */
					case '\\':		/* DOS	directory seperator */
							if (name[2] == '\0') {
								name[0] = '\0';
							}
							break;
					case '\0':
							name[0] = '\0';
							break;
					default:
							break;
				}
				break;
		case '\0' :
				name[0] = '\0';
				break;
		default:
				break;
	}
	(void) _mkname (dirp->dd_name, name);
	/*
	 *	Make sure that the trailing underscore is present,
	 *	and add it if not.	Then store final name length.
	 */
	for ( ch = 0, ptr = dirp->dd_name ; *ptr ; ptr++ ) {
		ch = *ptr;
	}
	if (ch != '_') {
		*ptr++ = '_';
		*ptr = '\0';
	}
	dirp->dd_namelen = (short)((long)ptr - (long)dirp->dd_name);
	/*
	 *	Try and access the name given as a directory
	 *	Take error exit if access fails
	 */
	if ((ret = open_qdir(dirp->dd_name)) <= 0) {
		if (ret< 0) {
			errno = EOSERR;
			_oserr = ret;
		}
		return (NULL);
	}
	/*
	 *	We want to try and ensure that the inode field is unique
	 *	as a number of unix programs (particularily GNU ones)
	 *	often compare two inodes to see if two files are really
	 *	the same underlying file.
	 *
	 *	Use the file date as the inode, hopefully this gives
	 *	a good chance of getting a unique value.
	 */
	(void) fs_headr(ret, (timeout_t)-1, (char *)&header, sizeof(header));
	dirp->dd_buf.d_ino = header.d_update;
	dirp->dd_buf.d_off = (off_t)64;

	/*
	 *	Close the channel id we got
	 */
	(void) io_close(ret);
	return dirp;
}
