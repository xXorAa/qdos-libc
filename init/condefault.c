/*
 *      c o n d e f a u l t
 *
 *  Default console set-up routine if user does not specify any
 *  alternative.   This merely sets up the window as defined in
 *  the _condetails global variable and then clears the screen.
 *  However, none of the above is done if the channel has been
 *  passed by an parent job.
 *
 *  AMENDMENT HISTORY
 *  ~~~~~~~~~~~~~~~~~
 *  03 Sep 94   DJW   - Underscore added to name as part of implementing
 *                      name hiding within C68 libraries.
 */

#define __LIBRARY__

#include <qdos.h>

void    _consetup_default  (chanid, condetails)
  chanid_t  chanid;
  struct WINDOWDEF * condetails;
{
    (void) sd_wdef(chanid, (timeout_t)-1, condetails->border_colour,
                                   condetails->border_width,
                                   (struct QLRECT *)&condetails->width);
    (void) sd_setst(chanid, (timeout_t)-1, condetails->paper);
    (void) sd_setpa(chanid, (timeout_t)-1, condetails->paper);
    (void) sd_setin(chanid, (timeout_t)-1, condetails->ink);
    (void) sd_clear( chanid, (timeout_t)-1);
}

