/*								f r e o p e n							   */

#include "stdiolib.h"

#ifdef QDOS
#include "qdos.h"
#endif /* QDOS */

/*LINTLIBRARY*/

FILE *freopen F3(CONST char *, name, CONST char *, mode, register FILE *, fp)

{
  register int nfd; 		/* opened file descriptor */
  register int ofd; 		/* old file descriptor */
  int dupstat;				/* duplicate descriptor status */
  short flags;				/* flag settings */

/* Synchronise this stream */
  (void) FFLUSH(fp);

#ifdef QDOS
  (void) close(fileno(fp));
  ofd = -1;

/* Open according to the specified mode */
	if ((nfd = __fopen(name, mode, -1, &flags)) >= 0) {
/* New file opened ok on new file descriptor */
/* Free any buffers */
	  __freebuf(fp);

/* Initialise the new stream descriptor */
	  return __file(fp, nfd, flags);
	}
#endif /* QDOS */

#ifndef QDOS
  for (ofd = fileno(fp); ; ) {

/* Open according to the specified mode */
	if ((nfd = __fopen(name, mode, -1, &flags)) < 0) {

/* Something wrong with open */
	  if (errno != EMFILE)
		break;

/* All file descriptors in use --- ok to close first then retry */
	  else {
		(void) close(ofd);
		ofd = -1;
	  }
	}

/* New file opened ok on new file descriptor */
	else {
	  if (ofd >= 0) {
	fp->__file = -1;
	dupstat = dup2(nfd, ofd);
	(void) close(nfd);
	if (dupstat < 0)
	  break;
	nfd = ofd;
	  }

/* Free any buffers */
	  __freebuf(fp);

/* Initialise the new stream descriptor */
	  return __file(fp, nfd, flags);
	}
  }
#endif /* ! QDOS */

/* Something badly wrong */
  (void) fclose(fp);
  return NULL;
}
