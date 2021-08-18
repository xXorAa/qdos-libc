/*
 *					r e a d k b d _ m o v e
 *
 *	This file contains a replacement for io_fbyte, which is
 *	supposed to be called from _conread(), if the _readkbd
 *	vector is set up to point to it.
 *
 *	The readkbd_move routine will use the standard Pointer Environment
 *	support routines so that the screen can be moved using either the
 *	keyboard or the mouse.
 *
 *
 *
 *	AMENDMENT HISTORY
 *	~~~~~~~~~~~~~~~~~
 *	13 Apr 94  EAJ	Initial version
 *
 *	27 Apr 94  EAJ	Altered significantly (old source saved as _readmouse_old)
 *					Only check for CTRL-F4, using io_fbyte, as reading
 *					the keyboard through iop.rptr get confusing when
 *					user presses the cursor keys: The pointer moves, when
 *					maybe, as in Elvis, only a cursor move was intended.
 *					This means that clicking on the frame is no longer
 *					possible, use CTRL F4 instead.
 *
 *	03 Jul 94	DJW   - Changed name to readkbd_move() as more consistent with
 *						naming used for other vectors within C68 system.
 *					  - Replaced QDOS? calls by direct calls to the named
 *						support routines as this is clearer.
 *
 *	16 Sep 94	DJW   - Changed to use new getsddata() routine instead ofthe
 *						routines getwdef() and getcurss() which have now been
 *						rempved from the library.  This allows for getting
 *						addresses straight from the channel definition block.
 *						This seems better than using the _condetails area as
 *						the user might have changed the window since the
 *						original program initialisation.
 *					  - Corrected faults introduced while changing to direct
 *						iop_???? calls (and not getting it quite right!).
 *
 *	??			EAJ   - Now position pointer in centre of screen.
 */

#define TESTING 0				/* 0 for library module, 1 for test program */

#define __LIBRARY__

#include <qdos.h>
#include <qptr.h>
#include <channels.h>
#if TESTING
#include <stdio.h>
#include <unistd.h>
#endif /* TESTING */

int readkbd_move(chanid_t chanid, timeout_t timeout, char *char_pointer)
{
	int retval;
	struct WM_prec ptrrec;
	struct QLRECT sizpos[1];
	struct QLRECT limits[1];
	struct QLRECT wdef[1];
	const struct scrn_info *sddata; 		/* Standard screen control block */
	const struct scrn_xinfo *qptrdata;		/* Extended screen control block */
	short px,py,dx,dy;
	char cursor_state;
	short cursor_x, cursor_y;
	short calcval;
	int reply;

	/*
	 *	If not our channel, then don't even consider doing fancy stuff
	 *	like moving the screen. It might confuse the owner of the channel.
	 */
	if( _get_chown(chanid) != _Jobid ) {
		return io_fbyte(chanid,timeout,char_pointer);
	}

	for(;;)
	{
		/*
		 *	Flush any pending output
		 */
		(void) sd_donl(chanid,timeout);
	
		/*
		 *	read keyboard
		 */
		retval = io_fbyte(chanid,timeout,char_pointer);

		/*
		 *	if an error occurred (probably timeout) or
		 *	not CTRL F4 pressed, just return as usual
		 */
		if( retval || (*(unsigned char *)char_pointer != 245) ) {
			break;
		}
		/*
		 *	We have a move request !
		 *
		 * read initial pointer position
		 *	Exit if no PE present
		 */
		px = 0; py = 0;
		reply = iop_rptr (chanid, -1, &px, &py, 0x30, &ptrrec);
		if (reply != -1 && reply != 0) {
			break;
		}
		/*
		 *	Get the window control block pointers
		 *	And save some important information
		 */
		(void) _Getsddata( chanid, &sddata);
		qptrdata = (struct scrn_xinfo *)((char *)sddata - sizeof(struct scrn_xinfo));
		/*
		 *	disable cursor
		 *	get window size and cursor pos.
		 */
		cursor_state = sddata->sd_curf;
		cursor_x = sddata->sd_xpos;
		cursor_y = sddata->sd_ypos;
		(void) sd_curs (chanid, -1);
		sizpos->q_x = sddata->sd_xmin;
		sizpos->q_y = sddata->sd_ymin;
		sizpos->q_width = sddata->sd_xsize;
		sizpos->q_height = sddata->sd_ysize;

		/*
		 *	position pointer in the centre of the screen
		 *	this looks nicer
		 */
		px = (short)(sizpos->q_width / 2);
		py = (short)(sizpos->q_height / 2);
		(void) iop_sptr(chanid,  -1, &px, &py, -1);

		/*
		 * use window move sprite and get dx,dy
		 * and find limits and adjust accordingly
		 */
		dx = px;	/* Are these two lines necessary ? DJW */
		dy = py;
		(void) iop_rptr (chanid, -1, &dx, &dy, 0x81, &ptrrec);
		dx -= px;
		dy -= py;
		dx &= ~1; /* only allow even changes */
		dy &= ~1; 
		(void) iop_flim (chanid, -1, (struct WM_wsiz *)limits);
#if TESTING
		(void) printf ("limits: q_x=%d, q_y=%d, q_width=%d, q_height=%d\n",
					limits->q_x, limits->q_y, limits->q_width, limits->q_height);
#endif
		/*
		 *	We can calculate limits using the old values of
		 *	the outline size and hit size.	This should be
		 *	more reliable than the previous method of relying
		 *	on the _condetails structure still being valid
		 *	(as well as more effecient in code!).	 DJW
		 */

		calcval = (short)(limits->q_x - qptrdata->sd_xouto);
		if (dx < calcval ) {
			dx = calcval;
		} else {
			calcval = (short)((limits->q_x + limits->q_width)
								-(qptrdata->sd_xouto + qptrdata->sd_xouts));
			if (dx > calcval) {
				dx = calcval;
			}
		}

		calcval = (short)(limits->q_y - qptrdata->sd_youto);
		if (dy < calcval ) {
			dy = calcval;
		} else {
			calcval = (short)((limits->q_y + limits->q_height)
							-(qptrdata->sd_youto + qptrdata->sd_youts));
			if (dy > calcval) {
				dy = calcval;
			}
		}

		wdef->q_x = (short)(qptrdata->sd_xhito + dx);
		wdef->q_y = (short)(qptrdata->sd_yhito + dy);
		wdef->q_width  = qptrdata->sd_xhits;
		wdef->q_height = qptrdata->sd_yhits;
		/*
		 *	calculate suitable shadow
		 *	(i.e. keep current values)
		 */
		px = (short)(qptrdata->sd_xouts - qptrdata->sd_xhits);
		py = (short)(qptrdata->sd_youts - qptrdata->sd_yhits);
#if TESTING
printf ("dx=%d, dy=%d,   px=%d, py = %d\n", dx, dy, px, py);
		(void) printf ("wdef: q_x=%d, q_y=%d, q_width=%d, q_height=%d\n",
					wdef->q_x, wdef->q_y, wdef->q_width, wdef->q_height);
#endif /* TESTING */
		/*
		 *	move window
		 *	reset window definition after adjusting for move
		 */
		(void) iop_outl (chanid, -1, px, py, 1, &wdef);
		sizpos->q_x += dx;
		sizpos->q_y += dy;
		(void) sd_wdef (chanid, -1, sddata->sd_bcolr, sddata->sd_borwd, sizpos);
		/*
		 *	re-position cursor
		 *	reset cursor to original state
		 */
		(void) sd_pixp (chanid, -1, cursor_x, cursor_y);
		if( cursor_state != 0 ) {
			(void) sd_cure (chanid, -1);
		}
		/*
		 *	go round loop again
		 */
	}

	return retval;
}


#if TESTING
/*
 *	This code can be used to generate a free-standing test program
 *	for checking out the readkbd_move routine by simply setting
 *	TESTING to true.
 */


int (* _readkbd)(chanid_t, timeout_t, char *) = readkbd_move;
void (* _consetup)() = consetup_title;
char _prog_name[] = "readkbd_move() test";

void chaninfo(chanid_t chid)
{
	struct scrn_info  * ptr;
	struct scrn_xinfo * xptr;

	(void)_Getsddata(chid,&ptr);

	xptr = (struct scrn_xinfo *)((char *)ptr - sizeof(struct scrn_xinfo));

	(void) printf ("sd_xhits=%d,  sd_yhits=%d,  sd_xhito=%d,  sd_yhito=%d\n",
					xptr->sd_xhits, xptr->sd_yhits, xptr->sd_xhito, xptr->sd_yhito);

	(void) printf ("sd_xouts=%d,  sd_youts=%d,  sd_xouto=%d,  sd_youto=%d\n",
					xptr->sd_xouts, xptr->sd_youts, xptr->sd_xouto, xptr->sd_youto);

	(void) printf ("sd_xsize=%d,  sd_ysize=%d,  sd_xmin=%d,  sd_ymin=%d,\n",
					ptr->sd_xsize, ptr->sd_ysize, ptr->sd_xmin, ptr->sd_ymin);

	(void) printf ("sd_xpos=%d,   sd_ypos=%d,  sd_curf=%d\n",
					ptr->sd_xpos, ptr->sd_ypos, ptr->sd_curf);

	return;
}

main()
{
	char buffer[20];
	chanid_t chid = fgetchid(stdout);

	chaninfo(chid);

	for ( ; ; ) {
		(void) read(fileno(stdin), buffer,sizeof(buffer));
		chaninfo (chid);
	}
}

#endif /* TESTING */
