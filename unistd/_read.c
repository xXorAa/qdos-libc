/*
 *			r e a d _ c
 *
 *	Routine to simulate the UNIX 'read' system call.
 *
 * Handles reading from all the different types of device.
 *
 *	06/05/92	DJW 	Corrected error in handling of console
 *						device where bufffer pointer incremented
 *						twice for each character read !
 *	07/08/92	EJ		Use io_edlin instead of io_fline, to provide extra
 *						functions via the ability to terminate input with
 *						arrow up/down characters. Behaviour when terminating
 *						input with enter is of course unchanged. The extra
 *						functions are:
 *							Terminating char.	Behaviour
 *							arrow up			The contents of the input-
 *												buffer is interpreted as a
 *												number, and the corresponding
 *												character is returned. Useful
 *												for entering control-characters
 *												and tabs, etc.
 *							arrow down			The contents of the input-
 *												buffer is returned WITHOUT
 *												the terminating character.
 *												If the buffer is empty, then
 *												the higher level I/O will see
 *												this as EOF.
 *						The result of these extra functions are that ABSOLUTELY
 *						ANY characters (including EOF) can be entered from the
 *						keyboard, even without recourse to using raw mode.
 *
 *	20/09/92	DJW 	The Console read routine made into a vector.
 *
 *	14/10/92	DJW 	The Console read vector can now be set to NULL to get
 *						default input with no translation (or editing).
 *
 *	14 Jul 93	DJW   - Removed assumption that io_fstrg() sets _oserr.
 *
 *	11 Jul 95	RZ	  - fix to return EINTR when interrupted.
 *
 *	12 Nov 95	DJW   - added support for UFB_NB (Posix O_NONBLOCK) mode
 *					  - Now get timeout via support routine to allow for
 *						the setting of the UFB_ND and UFB_NB flags.
 *
 *	 8 Jun 96	RZ	  - changed to use system call functionality of
 *						signal extension
 *
 *	07 Dec 96	DJW   - Corrected problem introduced when changes made for
 *						signal handling that stopped reads of a disk file
 *						greater than 32K working correctly.
 *
 *	08 Aug 98	DJW   - Included changes for socket handling.
 *						(based on changes supplied by Jonathan Hudson)
 */

#define __LIBRARY__

#include <qdos.h>
#include <fcntl.h>
#include <stdlib.h>
#include <unistd.h>
#include <errno.h>
#include <sys/signal.h>
#include <sys/socket.h>

#define min(x,y) ((x) > (y) ? (y) : (x))

static int sys_read _LIB_F3_( int,			   fd,	   \
					   void *,			buf,	\
					   unsigned int,	len)
{
	UFB_t *   uptr;
	long	  totread;
	long	  to_read;
	long	  num_read;

	sigset_t *pf;
	int is_atomic;

	/*
	 *	Check that we have a UFB for this file,
	 *	and if not make an error return.
	 */
	if ((uptr = _Chkufb( fd ))== NULL)
	{
		return (-1);
	}

	/*
	 *	Check that read access allowed,
	 *	and if not make an error return.
	 */
	if ((uptr->ufbflg & UFB_RA) == 0) 
	{
		errno = EACCES;
		return -1;
	}

	/*
	 *	Determine whether read should be 
	 *	interruptible by signals.
	 */
	is_atomic = (uptr->ufbtyp == D_DISK);
	pf = (sigset_t *)SYSCTL(is_atomic ? 0 : SCTL_EXP );

	/*
	 *	Do a different read for device types
	 */
	switch( uptr->ufbtyp ) 
	{
		case D_CON:
			if (_conread != NULL) 
			{
				num_read=((*_conread) (uptr, buf, len));
				/*
				 *	If the read was interrupted by a signal
				 *	and no data had been read set up the
				 *	appropriate error code in errno.
				 */
				if (num_read <= 0 && SYS_PENDING(pf))
				{
					errno = EINTR;
				}
				return num_read;
			}
			/* FALL THRU */
		case D_AUX:
		case D_PIPE:
		case D_DISK:
			totread = 0L;
			/* 
			 * Cater for reads of greater than 32K 
			 * (maximum io_fstrg handles)
			*/
			do 
			{
				to_read = min( (long)len, (32L*1024L-1L));
				if(( num_read = io_fstrg( uptr->ufbfh, _GetTimeout(uptr), 
						buf, (short)to_read )) < 0) 
				{
					switch (num_read) 
					{
						case ERR_EF:	/* Only acceptable error is EOF */
							return (int)totread;
						case ERR_NC:	/* Acceptable in no delay reads only */
							if (uptr->ufbflg & UFB_ND) 
							{
								return (int)totread;
							} 
							else if (uptr->ufbflg & UFB_NB) 
							{
								if (totread <= 0) 
								{
									errno = EAGAIN;
									_oserr=(int)num_read;
									return -1;
								} 
								else 
								{
									return (int)totread;
								}
							} 
							else if (SYS_PENDING(pf))
							{
									  goto lab99;
							}
						default:		/* all other errrors */
							errno = EOSERR;
							_oserr = (int)num_read;
							return -1;
					}
				}
				len -= num_read;
				totread += num_read;
				((char *)buf) += num_read;
			} 
			while (num_read == to_read
				  && (len != 0L) 
				  && (is_atomic || SYS_PENDING(pf)==0));
	   lab99:
			if (totread>0 || SYS_PENDING(pf)==0)
			{
				return (int)totread;
			}
			errno = EINTR;
			return -1;
	case D_PRN:
			errno = EINVAL;
			return -1;
	case D_NULL:
			_oserr = (short)ERR_EF; 		/* Set QDOS EOF code */
			uptr->ufbst |= (char)UFB_EOF;	 /* ... and set flag in UFB */
			return 0;
	case D_SOCKET:
			return recv(fd, buf, len, 0);
	default:
			errno = ENODEV;
			return -1;
	}
	/* NOT REACHED */
}


int read _LIB_F3_( int, 			fd, 	\
				   void *,			buf,	\
				   unsigned int,	len)
{
	struct SYSCTL sctl;

	/* 
	 *	check for signal extension not present 
	 *	or other failure
	 */
	if (SYSCALL3(0,&sctl,sys_read,fd,buf,len) < 0)
	{
		return sys_read(fd,buf,len);
	}

	/*
	 *	Check for fatal exception inside sys_read
	 */
	if (sctl.pending & _SIG_FTX)  
	{
		errno=EFAULT;
		return -1;
	}

	return	sctl.rval;
}
