/*
 *			_ f o r k e x e c
 *
 * Internal library routine to perform a fork/exec call,
 * creating the job given
 *		a file name,
 *		a parameter to pass to opene(),
 *		channel id's to pass to the job,
 *		the command line to pass to the job.
 *
 *	VERSION HISTORY
 *	~~~~~~~~~~~~~~~
 *	11 Sep 92	DJW   - Removed the option for passing QDOS channels as it
 *						was never used (by the forkexec library calls).
 *					  - Changed the code for handling default channels to
 *						make it simpler and smaller.
 *
 *	22 Oct 92	DJW   - Added code to set top bit of PIPE channels passed
 *						on the stack.
 *
 *	08 Jun 93	DJW   - Modified code to only set top bit of PIPE channels
 *						when they are also in WRITE mode.	Added code to
 *						change owner of such channels to target job.
 *
 *	10 Jul 93	DJW   - Removed dependency on mt_cjob() call setting _oserr.
 *	11 Jul 93	DJW   - Removed dependency on fs_load() call setting _oserr.
 *	22 Aug 93	DJW   - Removed dependency on mt_activ() call setting _oserr.
 *
 *	26 Jan 94	DJW   - Allowed for the 'channel[0]' parameter to be -1. This
 *						is treated the same as the pointer 'channels' being
 *						-1 as this seems to be a common misinterpretation of
 *						the documentation.
 *
 *	7  Apr 94	EAJ   - Only change the ownership of pipes, do NOT set
 *						the top bit of the channel id. This behaviour was
 *						totally incompatible with anything else in the QDOS
 *						world, and we do not want to prevent people from
 *						writing programs using, say, Q_Liberator, and then using
 *						these programs with the C68 system.
 *						This change is accompanied by a corresponding change
 *						in init__stkchans_c, which detects the ownership.
 *
 *	11 Apr 94	EAJ   - Added call to _waitforjob, if fork().
 *
 *	16 Apr 94	EAJ   - Added code that cooperates with code in init__cmdparse_c
 *						to ensure that arguments that contain spaces, etc.
 *						are treated correctly by the receiving program, ie.
 *						NOT split up into separate arguments. GNU diff uses
 *						this feature (in util_c, where it forks off a "pr"
 *						process)!
 *
 *	20 Jul 94	DJW   - Meaning of last parameter changed to allow for
 *						implementiation of qfork() family of routines.	Now:
 *							0	Exec
 *							-ve Fork, and set job as belonging to this one.
 *
 *	28 Aug 94	DJW   - Changed to use new library routine argpack() (and the
 *						underlying __streadd()) to build up command line.
 *
 *	15 Jan 95	DJW   - If their is an error after creating the job, it was
 *						not being removed from memory before returning an
 *						error code to the caller.
 *						Problem reported by Richard Zlidwicky
 *
 *	17 Mar 98	DJW   - Delay added after launching a program in attempt to
 *						cure "freezes" encountered on SMSQ/E QXL systems.
 *						(Problem + fix reported by Thierry Godefroy).
 *
 *	10 Dec 98	DJW   - Added DBG diagnostic calls as part of helping
 *						debug a problem reported with CC.
 */

#define __LIBRARY__

#include <qdos.h>

#include <errno.h>
#include <fcntl.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

/* #define LIBDEBUG 		/* Uncomment to add test/diagnostic code	*/
							/* N.B. Needs LIBDEBUG library at link time */

#ifdef LIBDEBUG
#include <debug.h>
#else
#define DBG(params)
#endif /* LIBDEBUG */

extern long _def_priority;

struct chans {
	short no_chans;
	chanid_t chan_ids[1];
};

static int defaultchans[] = {3,-1,-1,-1};

long _forkexec _LIB_F5_(const char *,	name,		\
						int,			op_param,	\
						int *,			channels,	\
						char * const *, argv,		\
						jobid_t,		f_or_e) /* 0 if exec, owner if fork */
{
	struct qdirect hdrbuf;
	struct JOBHEADER *jobhdr;		/* Header for job we will create */
	long	progsize;				/* Size of program */
	long	datasize;				/* Sizes of static data */
	char	*jobaddr;				/* Job start address */
	char	*job_a7, *p, *p1;		/* a7 pointer, general pointers */
	short	comllen;				/* Length of actual command line */
	char *	comptr; 				/* Text of actual command line */
	jobid_t new_jobid;				/* Job id to return on fork */
	short	i;
	int 	fd; 					/* File descriptor from opene */
	int 	reply;
	int 	*fds_ptr;
	struct chans *chans_p;

	DBG(("_FORKEXEC", 0x11, "Entered: name=%s, op_param=%d, f_or_e=$%p", \
										name, op_param, f_or_e));

	/*
	 *	Open the program file
	 */
	DBG(("_FORKEXEC", 0x14, " open program file '%s'", name));

	if((fd = opene( name, O_RDONLY, op_param)) == -1)
	{

		DBG(("_FORKEXEC", 0x11, "Exit -1: open failed", name));

		return -1;
	}
	/*
	 *	Read the file header
	 */
	DBG(("_FORKEXEC", 0x14, " read file header"));
	if( (reply = fqstat( fd, &hdrbuf)) != 0) 
	{

		DBG (("_FORKEXEC",0x11,"Exit -1: fqstat failed: reply=%d, errno=%d, _oserr=%d", \
								reply, errno, _oserr));

		(void) close( fd );
		_oserr = reply;
		errno = EOSERR;
		return -1;
	}

	/*
	 *	Check if this is an executable file
	 *	If not, then make an error exit
	 */
	DBG(("_FORKEXEC", 0x14, " check file is executable"));
	if( hdrbuf.d_type != QF_PROG_TYPE)
	{

		DBG(("_FORKEXEC", 0x14, "Exit -1: file type (%d) check failed.", \
									hdrbuf.d_type));

		(void) close( fd );
		_oserr = ERR_FE;
		errno = EOSERR;
		return -1;
	}

	progsize = hdrbuf.d_length; /* Length of file */

	/*
	 *	Work out the space needed to pass any channels
	 */
	switch( (long)channels)
	{
	case 0L:	/* == NULL */
			/* No channels to pass */
			fds_ptr = (int *)&channels;
			break;
	default:
			/*
			 *	specified channels to be passed
			 *	N.B.  If channel count is -1, then we
			 *	assume the same as passing a pointer -1.
			 */
			if (channels[0] != -1) 
			{
				fds_ptr = channels;
				break;
			}
			/* FALL THRU */
	case -1L:
			/*	default channels to be passed		 */
			/*	stdin (0), stderr (2) and stdout (1) */
			fds_ptr = defaultchans;
			break;
	}

	/*
	 *	Build up the command line.	At this stage, assume
	 *	the target is a C program as this is worst case
	 *	for require space.
	 */

	DBG(("_FORKEXEC", 0x14, " build up command line"));
	comptr = argpack(&argv[1],1);
	if (comptr == NULL)
	{
		DBG(("_FORKEXEC", 0x11, "Exit -1: argpack() failed. errno=%d, _oserr=%d", \
							errno, _oserr));
		errno = ENOMEM;
		return -1;
	}
	comllen = (short) strlen(comptr);

	/*
	 *	Add the space needed for the command line (including
	 *	2 byte field for command line length, and rounded up
	 */
	datasize = *fds_ptr * 4 + 6;   /* Channels + count + 0L */
	datasize += hdrbuf.d_datalen + ((comllen + 3)&~1);

	/*
	 *	Add the space for the environment pointer
	 */
	datasize += sizeof(char *) + 2;  /* add 2 bytes for magic number */

	/*
	 *	Create the job
	 */
	DBG(("_FORKEXEC", 0x14, " create job"));
	if ((new_jobid = mt_cjob( (long)progsize, (long)datasize,
				  (char *)NULL, 					/* Start address */
				   f_or_e ? f_or_e : (jobid_t)-1,	/* Owner job */
				   &jobaddr)) < 0L ) 
	{
		/* Create job failed */

		DBG(("_FORKEXEC", 0x11, "Exit -1: mt_cjob failed. _oserr=%d", \
								new_jobid));

		(void) close( fd );
		_oserr = new_jobid;
		errno = EOSERR;
		return -1;
	}
	/*
	 *	Load the file into this area
	 */
	DBG(("_FORKEXEC", 0x14, " load job"));
	if( (reply = fs_load( (chanid_t)getchid( fd ), (char *)jobaddr,
											(long)progsize )) != progsize) 
	{

		DBG(("FORKEXEC", 0x11, "Exit -1: fs_load failedL _oserr=%d", \
								reply));

		(void) close( fd );
		_oserr = reply;
		errno = EOSERR;
		(void) mt_frjob (new_jobid, ERR_NC);   /* remove failed job */
		return -1;
	}
	/*
	 *	Close the program file
	 */
	(void) close( fd );


	/*
	 *	Is this really a C68 C program ?
	 *
	 *	I have no idea if this test is too strict or too "loose", but
	 *	I think it will do, as a starting point ! Erling Jacobsen.
	 *
	 *	If not, then we need to rebuild the command line according
	 *	to non-C rules, and calculate new conlen, etc.
	 */
	DBG(("_FORKEXEC", 0x14, " check if target is C68 program ($%08.8lx '%6.6s')",
								*(long *)(jobaddr+6), jobaddr+10));
	if (memcmp("\x4a\xfb\x00\x06" "C_PROG",jobaddr+6,10))
	{
		DBG(("_FORKEXEC", 0x14, "  target program not a C68 one"));
		free (comptr);
		comptr = argpack (&argv[1],0);
		if (comptr == NULL) 
		{
			DBG(("_FORKEXEC", 0x11, "Exit -1:  argpack failed. errno=%d, _oserr=%d", \
									errno, _oserr));

			errno = ENOMEM;
			(void) mt_frjob (new_jobid, ERR_NC);   /* remove failed job */
			return -1;
		}
		comllen = (short)strlen(comptr);
	}
	/*
	 *	Get at the job header before the job address, and
	 *	add the required information to it's stack
	 */
	jobhdr = (struct JOBHEADER *)( jobaddr - sizeof( struct JOBHEADER ));
	job_a7 = (char *)jobhdr->jb_regs.jb_A7; /* Get stack pointer */

	/*
	 *	Insert the enviroment pointer
	 */
	DBG(("_FORKEXEC", 0x14, " insert environment pointer into job stack"));
	job_a7 -= 4;
	*((long *)job_a7) = (long)_VENV;		 /* environment pointer */

	/*
	 *	Insert the comand line
	 *	(Subtract even command line length plus 2 for length)
	 */
	DBG(("_FORKEXEC", 0x14, " insert command line into job stack\n (%s)", comptr));
	p1 = (job_a7 -= 2);
	p = ( job_a7 -= ((comllen+3)&~1)) + 2;
	(void) strncpy (p, comptr, comllen);
	free (comptr);
	*(short *)job_a7 = comllen; /* Set up length field */

	/*
	 *	Magic number must be inserted after command line was
	 *	added as adding command line overwrites one byte of
	 *	magic number
	 */
	DBG(("_FORKEXEC", 0x14, " insert magic number ($%04.4x) into job stack", ENV_MAGIC));
	*(short *)p1 = ENV_MAGIC;

	/*
	 *	Put channels on stack
	 */
	DBG(("_FORKEXEC", 0x14, " insert channels into job stack"));
	if ( channels == NULL )
	{
		/*
		 *	No channels to pass, put a word of zero on
		 *	the stack to tell the program this
		 */

		DBG(("_FORKEXEC", 0x14, "  no channels to pass"));
		job_a7 -= 2;
		*(short *)job_a7 = 0;
	}
	else 
	{
		/*
		 *	-1 = Child program to use same channels as parent
		 * +ve = Child program to use specified channels
		 */
		DBG(("_FORKEXEC", 0x14, "  %d channels to add", (short)(*fds_ptr)));
		job_a7 -= 2 + (4 * *fds_ptr);		   /* Make room */
		chans_p = (struct chans *)job_a7;
		chans_p->no_chans = (short)(*fds_ptr);
		for( i = 0; i < *fds_ptr; i++) 
		{
			int fdc;
			struct UFB *uptr;
			if ((fdc = (int)fds_ptr[i+1]) == -1) 
			{
				switch (i) 
				{
				case 1:
						fdc = 2;
						break;
				case 2:
						fdc = 1;
						break;
				default:
						fdc = i;
						break;
				}
			}
			uptr = _Chkufb(fdc);				/* Get file control area */
			chans_p->chan_ids[i] = uptr->ufbfh;
			DBG(("_FORKEXEC", 0x14, "  %d: handle=%d, chanid=%08.8x", \
									i, fdc, uptr->ufbfh));
			/*
			 *	For the special case of PIPE channels in write mode
			 *	we need to do the following additional processing:
			 *	 a)  Set the top bit in the channel id on the stack
			 *		 to stop the start-up code in the target program
			 *		 from setting the NO_CLOSE attribute on the channel.
			 *
			 *		 Erling Jacobsen, Apr 1994: This is NOT DONE, as this
			 *		 is entirely too QDOS uncompatible.
			 *
			 *	 b)  Change the owner of the channel to the target
			 *		 program so that if it is killed, QDOS will do an
			 *		 automatic close on the channel.
			 *	This is needed for calls like popen() to function in
			 *	a correct manner.
			 *
			 *	EJ: If the NC flag is set, then the channel is not to be
			 *	closed by us, and consequently not by our children either!
			 *
			 *	EJ: This code is beginning to look a bit weird, but at
			 *	least popen(), and most un*x-like fork()/exec() situations
			 *	work OK. I have checked this on CPROTO and GNU DIFF3.
			 */
			if ( (uptr->ufbtyp == D_PIPE) &&
				 ((uptr->ufbflg&UFB_NC)==0) )  /* don't allow child to
													   close, if we are not
													   allowed ourselves */
			{ 
				(void) _ch_chown(uptr->ufbfh, new_jobid);
				uptr->ufbflg |= UFB_NC;
			}
		}
	}

	/*
	 *	Set the new a7 value back into the jobs register values
	 */
	jobhdr->jb_regs.jb_A7 = (addreg_t)job_a7; /* Set stack pointer */
	/*
	 *	If fork() ensure that the job will return it's error code
	 *	through the _waitforjob() system. See misc_wait_x.
	 *
	 *	Now activate the job
	 *		either waiting for it to finish and
	 *			   returning its error code (exec )
	 *		or returning it's job id (fork)
	 */
	DBG(("_FORKEXEC", 0x14, " activate job (f_or_e = %d)", f_or_e));
	if( f_or_e )
	{
		reply = _waitforjob((jobid_t)new_jobid);
	}
	reply = mt_activ( (jobid_t)new_jobid, (char)_def_priority,
					 f_or_e ? (timeout_t)0 : (timeout_t)-1);
	if( reply != 0) 
	{
		DBG(("_FORKEXEC", 0x11, "Exit -1: mt_activ failed:( value returned=%d)", \
								reply));

		(void) mt_frjob (new_jobid, ERR_NC);   /* remove failed job */
		_oserr = reply;
		errno = EOSERR;
		return -1;
	}

	if (f_or_e) 
	{
		/*
		 *	The following suspend is to get around a potential problem
		 *	when a 'fork' is done and the parent job changes the
		 *	environment before the child can make a copy.  We therefore
		 *	give the child's start-up code a chance to complete to
		 *	try and avoid this situation.	Hopefully the delay is long
		 *	enough?   In theory it should be calibrated to the processor
		 *	speed, but this is far too much work so just make it large
		 *	enough for all realistic cases.
		 */
		(void) mt_susjb ((jobid_t)-1, (int)25, NULL);

		DBG(("_FORKEXEC", 0x11, "Exit $%08.8x: fork OK", new_jobid));

		return new_jobid;
	} 
	else 
	{
		/*
		 *	The following suspend is to get around a problem reported
		 *	when running SMSQ/E on QXL based systems.  Why the need to
		 *	let the system perform a re-schedule is not clear.
		 */
#if 0
		(void) mt_susjb ((jobid_t)-1, (int)2, NULL);
#endif
		DBG(("_FORKEXEC", 0x11, "Exit 0:  Exec OK"));

		return 0;
	}
}
