/*
 *	 c o n s e t u p _ t i t l e
 *
 *	This routine is one of the standard C68 console set-up routines
 *	(although not the default).   It sets up a window plus title bar
 *	along the style used by QJUMP Pointer Environment programs.  It
 *	also sets up a "Outline Window" if pointer Environment is in use.
 *
 *	AMENDMENT HISTORY
 *	~~~~~~~~~~~~~~~~~
 *	20 Aug 94	DJW   - Added qptr.h header file as iop_outl() now in this
 *						file with other qptr routiones.
 */

#define __LIBRARY__

#include <qdos.h>
#include <qptr.h>
#include <string.h>

struct ptrrec
{
	long  id;
	short subw;
	short x,y;
	char  bt1,bt2;
	long  event;
	short ww,wh,wx,wy;
};


void consetup_title(chanid, condetails)
  chanid_t	chanid;
  struct WINDOWDEF * condetails;
{
	struct	 QLRECT tmprect;
	struct	 QLRECT winlim;
	short	 active_width, active_y_offset;
	short	 border_x_width;
	short	 namelength, versionlength, copyrightlength;
	unsigned char bar_paper, bar_ink;
	unsigned short shadw,shadh;
	short	 x;
	struct WM_prec _ptrrec;

	/*
	 *	First we do some standard calculations to
	 *	avoid continually repeating them later.
	 */

	/*
	 *	The vertical border width is ALWAYS 2 * the horizontal
	 *	border width (height ?), because we measure the width in
	 *	pixel-coordinate units. In MODE 8, pixels have a width of 2 !
	 *
	 *	Erling Jacobsen ( aka EAJ )
	 */
	border_x_width	= (short)(2 * condetails->border_width);
	/* Odd width is a bad idea */
	condetails->width = (short)(condetails->width & (unsigned short)~1U);

	active_width	= (short)(condetails->width - (border_x_width * 2));
	active_y_offset = (short)(12 + (condetails->border_width * 2));
	namelength		= (short)strlen(_prog_name);
	versionlength	= (short)strlen(_version);
	copyrightlength = (short)strlen(_copyright);

	/*
	 *	Get the possible size of the window, use old QL size, if necc.
	 *
	 *	Erling Jacobsen
	 */
	if (iop_flim (chanid, -1, (struct WM_wsiz *)&winlim))
	{
		winlim.q_width = 512;
		winlim.q_height = 256;
		winlim.q_x = winlim.q_y = 0;
	}
	else
	{
		short px, py;
		/*
		 *	Place window where pointer is. We only get here if PE exists
		 */

		(void) iop_rptr (chanid, -1, &px, &py, 0x30, &_ptrrec);

		condetails->x_origin = (short)((px - (condetails->width >> 1)) & (unsigned short)~1U);
		condetails->y_origin = (short)(py - (condetails->height >> 1));

		/* Check that window is OK */

		if( (short)(condetails->x_origin) < (short)winlim.q_x )
			condetails->x_origin = winlim.q_x;

		if( (short)(condetails->y_origin) < (short)winlim.q_y )
			condetails->y_origin = winlim.q_y;

		if( condetails->x_origin + condetails->width > winlim.q_x + winlim.q_width )
			condetails->x_origin = (short)(winlim.q_x+winlim.q_width - condetails->width);

		if( condetails->y_origin + condetails->height > winlim.q_y + winlim.q_height )
			condetails->y_origin = (short)(winlim.q_y+winlim.q_height - condetails->height);
	}

	/*
	 *	Size the main window and set its colours.
	 *	Also try to set up a PE "outline window".
	 *	Only set up a "shadow" if room (Erling Jacobsen).
	 */
	if( (shadw = (short)(winlim.q_x + winlim.q_width - condetails->width - condetails->x_origin)) > 8 ) {
		shadw=8;
	}
	if( (shadh = (short)(winlim.q_height + winlim.q_y - condetails->height - condetails->y_origin)) > 5 ) {
		shadh=5;
	}
	/*
	 *	For some reason, sd_wdef works better, if called AFTER iop_outl. EAJ
	 */
	(void) iop_outl(chanid, (timeout_t)-1, shadw, shadh, 0,(struct WM_wsiz *)&condetails->width);

	(void) sd_wdef(chanid, (timeout_t)-1, condetails->border_colour,
										  condetails->border_width,
										  (struct QLRECT *)&condetails->width);
	/*
	 *	Set up the menu bar background.
	 *	We also want to ensure a sensible colour for menu_bar.
	 */
	tmprect.q_width   = active_width;
	tmprect.q_height  = (short)(active_y_offset - condetails->border_width);
	tmprect.q_x 	  = 0;
	tmprect.q_y 	  = 0;
	if (condetails->border_colour != condetails->ink) {
		bar_paper = condetails->border_colour;
		bar_ink   = condetails->ink;
	} else {
		bar_paper  = condetails->ink;
		bar_ink    = condetails->paper;
	}
	(void) sd_fill(chanid, (timeout_t)-1, bar_paper, &tmprect);
	(void) sd_setst(chanid, (timeout_t)-1, bar_paper);
	(void) sd_setin(chanid, (timeout_t)-1, bar_ink);
	/*
	 * Write copyright at start and version at end of title bar
	 *	Write program name centred in menu bar
	 */
	(void) sd_chenq(chanid, (timeout_t)-1, &tmprect);
	if (copyrightlength) {
		(void) sd_pixp(chanid, (timeout_t)-1, 4, 1);
		(void) io_sstrg(chanid, (timeout_t)-1, _copyright, copyrightlength);
	}
	if (versionlength) {
		x  = (short)((active_width * (tmprect.q_width - versionlength) / tmprect.q_width) - 4 );
		(void) sd_pixp(chanid, (timeout_t)-1, x, 1);
		(void) io_sstrg(chanid, (timeout_t)-1, _version, versionlength);
	}
	if (namelength) {
		x  = (short)(active_width * (tmprect.q_width - namelength) / tmprect.q_width / 2);
		(void) sd_pixp(chanid, (timeout_t)-1, x, 1);
		(void) io_sstrg(chanid, (timeout_t)-1, _prog_name, namelength);
	}
	/*
	 *	Now set up standard working window.
	 *	It is defined with no border to fit
	 *	inside the original one opened above.
	 */
	tmprect.q_width = active_width;
	tmprect.q_height = (short)(condetails->height - active_y_offset - condetails->border_width);
	tmprect.q_x = (short)(condetails->x_origin + border_x_width);
	tmprect.q_y = (short)(condetails->y_origin + active_y_offset);
	(void) sd_wdef (chanid, (timeout_t)-1, 0, 0, &tmprect);
	(void) sd_setpa(chanid, (timeout_t)-1, condetails->paper);
	(void) sd_setst(chanid, (timeout_t)-1, condetails->paper);
	(void) sd_setin(chanid, (timeout_t)-1, condetails->ink);
	(void) sd_clear(chanid, (timeout_t)-1);
	return;
}
