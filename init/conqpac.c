/*
 *                          consetup_qpac
 *
 *  This routine is one of the standard C68 console set-up routines
 *  (although not the default). It sets up a window plus title bar
 *  along the style used by Qpac II Pointer Environment programs.
 *  It also sets up a "Outline Window" if the pointer Environment is in 
 *  use. Derived from contitle_c by DJW - EMS, 931212.
 *
 *  Tries to resemble Qpac II window outline as close as possible. This
 *  means that it creates an inner border as well and that some colours 
 *  are fixed. Allowed colour combinations are: black/red, black/green,
 *  white/red, white/green. The inner border is always green. The border 
 *  width is ignored. The border colour is translated into one of the
 *  default colourways.
 *
 *  Added extra functions qpac_move(), qpac_resize(), qpac_sleep() and
 *  qpac_poll() to do a move, resize and sleep operations on the window. 
 *  Return Qdos error code on failure.
 *
 *  AMENDMENT HISTORY
 *  ~~~~~~~~~~~~~~~~~
 *  ?? Jan 94   ES    - Original version contributed by Eric Slagter
 *
 *  01 Mar 94   DJW   - Merged the various files provided by Eric into
 *                      a single source file.
 *                    - Added consetup_ as prefix to externally visible
 *                      routine names.
 */

#include <qdos.h>
#include <qptr.h>
#include <string.h>

/* default colourways */

#define bar_black_red       ((BLACK_M8) | ((BLACK_M8 ^ RED_M8)   << 3) | (1 << 6))
#define bar_black_green     ((BLACK_M8) | ((BLACK_M8 ^ GREEN_M8) << 3) | (1 << 6))
#define bar_white_red       ((WHITE_M8) | ((WHITE_M8 ^ RED_M8)   << 3) | (1 << 6))
#define bar_white_green     ((WHITE_M8) | ((WHITE_M8 ^ GREEN_M8) << 3) | (1 << 6))

/* use #defines instead of enum to avoid allocating a complete long 
   integer. Add typecasts to make the constant explicitely typed.   */

#define ev_kstroke  (event_t)(1 << 0)
#define ev_kpress   (event_t)(1 << 1)
#define ev_kup      (event_t)(1 << 2)
#define ev_move     (event_t)(1 << 3)
#define ev_outwin   (event_t)(1 << 4)
#define ev_inwin    (event_t)(1 << 5)
#define ev_reserved (event_t)(1 << 6)
#define ev_request  (event_t)(1 << 7)

typedef unsigned char key_t;
#define k_hit       (key_t)1
#define k_do        (key_t)2
#define k_cancel    (key_t)3
#define k_help      (key_t)4
#define k_move      (key_t)5
#define k_size      (key_t)6
#define k_sleep     (key_t)7
#define k_wake      (key_t)8
#define k_tab       (key_t)9


static  int _ConSetUpQpac(chanid_t chanid, const struct QLRECT *dimensions,
                        colour_t ink, colour_t paper, colour_t border_colour, 
                        char retain)
{
    short       s_mode = -1;
    short       s_type = -1;
    struct      QLRECT tmprect;
    struct      WM_wsiz size;
    short       active_width;
    short       active_y_offset;
    colour_t    bar_strip;
    short       namelength;
    short       versionlength;
    short       copyrightlength;
    short       shadw;
    short       shadh;
    short       x;

    /* First we do some standard calculations to avoid continually  */
    /* repeating them later.                                        */

    /* First find the screen limits. If there is no PI active, use  */
    /* default values.                                              */

    if(iop_flim(chanid, TIMEOUT_FOREVER, &size))
    {
        retain      = 0;
        size.xsize  = 512;
        size.ysize  = 256;
        size.xorg   = 0;
        size.yorg   = 0;
    }

    /* If the window doesn't fit return here with error out of      */
    /* range. Do this as first thing to allow for window move to    */
    /* work properly.                                               */

    if(dimensions->q_x + dimensions->q_width  > size.xorg + size.xsize ||
       dimensions->q_y + dimensions->q_height > size.yorg + size.ysize ||
       dimensions->q_x                        < size.xorg              ||
       dimensions->q_y                        < size.yorg              ||
       dimensions->q_width < 40                                        ||
       dimensions->q_height < 30)
    {
        return(ERR_OR);
    }

    /* Determine the border colour to be one of the Qpac II ones.   */
    /* Default is black/green for the default green border.         */

    switch(border_colour)
    {
        case(BLACK_M8):
        case(BLUE_M8):
            bar_strip = bar_black_red;
            break;

        case(RED_M8):
        case(MAGENTA_M8):
            bar_strip = bar_black_green;
            break;

        case(GREEN_M8):
        case(CYAN_M8):
        default:
            bar_strip = bar_white_red;
            break;

        case(YELLOW_M8):
        case(WHITE_M8):
            bar_strip = bar_white_green;
            break;
    }

    /* Find out the screen mode for this window and if it is mode 8 */
    /* change it. Qpac II windows only fit in mode 4 and mode 2.    */

    mt_dmode(&s_mode, &s_type);

    if(s_mode == 8)
    {
        s_mode = 4;
        mt_dmode(&s_mode, &s_type);
    }

    /* Determine the offset of the working window.                  */

    active_width    = (short)(dimensions->q_width - 4);
    active_y_offset = 12;

    /* Calculate only once...                                       */

    namelength      = (short)strlen(_prog_name);
    versionlength   = (short)strlen(_version);
    copyrightlength = (short)strlen(_copyright);

    /* Determine maximum shadows. Use screen dimensions fetched     */
    /* earlier with iop_flim() or default screen dimensions.        */

    if((shadw = (short)(size.xsize - dimensions->q_width - dimensions->q_x)) > 8)
    {
        shadw = 8;
    }

    if((shadh = (short)(size.ysize - dimensions->q_height - dimensions->q_y)) > 4)
    {
        shadh = 4;
    }

    /* Set the outline to be the complete visible window. Try to     */
    /* keep window contents for window move operations. If no PI is  */
    /* available, the call to sd_wdef() will set the outline anyway. */
    /* The outer border is always white.                             */

    (void)iop_outl(chanid, TIMEOUT_FOREVER, shadw, shadh, retain, 
            (struct WM_wsiz *)dimensions);
    
    (void)sd_wdef(chanid, TIMEOUT_FOREVER, WHITE_M8, 1, (struct QLRECT *)dimensions);

    if(!retain)
    {
        (void)sd_setpa(chanid, TIMEOUT_FOREVER, BLACK_M8);
        (void)sd_clear(chanid, TIMEOUT_FOREVER);

        tmprect.q_width     = active_width;
        tmprect.q_height    = active_y_offset;
        tmprect.q_x         = 0;
        tmprect.q_y         = 0;

        (void)sd_fill (chanid, TIMEOUT_FOREVER, bar_strip, &tmprect);
        (void)sd_setst(chanid, TIMEOUT_FOREVER, BLACK_M8);
        (void)sd_setin(chanid, TIMEOUT_FOREVER, WHITE_M8);

        /* Write copyright at start and version at end of title     */
        /* bar.  Write program name centred in menu bar.            */

        (void)sd_chenq(chanid, TIMEOUT_FOREVER, &tmprect);

        if(copyrightlength)
        {
            (void)sd_pixp (chanid, TIMEOUT_FOREVER, 0, 1);
            (void)io_sbyte(chanid, TIMEOUT_FOREVER, ' ');
            (void)io_sstrg(chanid, TIMEOUT_FOREVER, _copyright, copyrightlength);
            (void)io_sbyte(chanid, TIMEOUT_FOREVER, ' ');
        }

        if(versionlength)
        {
            x = (short)(active_width * (tmprect.q_width - versionlength - 2) /
                        tmprect.q_width);

            (void)sd_pixp (chanid, TIMEOUT_FOREVER, x, 1);
            (void)io_sbyte(chanid, TIMEOUT_FOREVER, ' ');
            (void)io_sstrg(chanid, TIMEOUT_FOREVER, _version, versionlength);
            (void)sd_clrrt(chanid, TIMEOUT_FOREVER);
        }

        if(namelength)
        {
            x  = (short)(active_width * (tmprect.q_width - namelength - 2) /
                        tmprect.q_width / 2);
            (void)sd_pixp (chanid, TIMEOUT_FOREVER, x, 1);
            (void)io_sbyte(chanid, TIMEOUT_FOREVER, ' ');
            (void)io_sstrg(chanid, TIMEOUT_FOREVER, _prog_name, namelength);
            (void)io_sbyte(chanid, TIMEOUT_FOREVER, ' ');
        }
    }

    /* Now set up standard working window. It is defined 4 and 2    */
    /* pixels less to leave room between the outer and inner        */
    /* border.                                                      */

    tmprect.q_width     = (short)(active_width         - 4);
    tmprect.q_height    = (short)(dimensions->q_height - active_y_offset - 3);
    tmprect.q_x         = (short)(dimensions->q_x      + 4);
    tmprect.q_y         = (short)(dimensions->q_y      + active_y_offset + 1);

    /* The "inner", working window must always be set up as it is   */
    /* spoiled by iop_outl() anyway. The inner border is always     */
    /* green.                                                       */

    (void)sd_wdef (chanid, TIMEOUT_FOREVER, GREEN_M8, 1, &tmprect);
    (void)sd_setpa(chanid, TIMEOUT_FOREVER, paper);
    (void)sd_setst(chanid, TIMEOUT_FOREVER, paper);

    if(!retain)
    {
        (void)sd_clear(chanid, TIMEOUT_FOREVER);
    }

    return(sd_setin(chanid, TIMEOUT_FOREVER, ink));
}

static int ResizeOrMove(chanid_t chanid, char domove)
{
    extern  struct  WINDOWDEF   _condetails;
    auto    int                 qderr;
    auto    struct  WM_wsiz     dummy;

    /* Check if we have the PI active. If not, do the window move/resize    */
    /* with keys. Else use the mouse pointer. The code for pointer movement */
    /* is quite a bit down...                                               */

    if(iop_flim(chanid, TIMEOUT_FOREVER, &dummy))
    {
        short               *x;
        short               *y;
        char                c;
        short               cc;
        unsigned    char    displace;

        if(domove)
        {
            x = (short *)&_condetails.x_origin;
            y = (short *)&_condetails.y_origin;
        }
        else
        {
            x = (short *)&_condetails.width;
            y = (short *)&_condetails.height;
        }

        for(;;)
        {
            /* Ensure only even displacements for alignment.            */

            displace = 2;

            if(!!(qderr = io_fbyte(chanid, TIMEOUT_FOREVER, &c)))
            {
                return(qderr);
            }

            cc = (short)(unsigned char)c;

            switch(cc)
            {
                case(196): /* shift-left */
                    displace = 10;
                case(192): /* left */
                {
                    if(*x <= 0)
                    {
                        *x = 0;
                    }

                    *x -= displace;
                    if(_ConSetUpQpac(chanid,
                        (const struct QLRECT *)&_condetails.width,
                        _condetails.ink, _condetails.paper,
                        _condetails.border_colour, domove))
                    {
                        *x += displace;
                    }

                    break;
                }

                case(204): /* shift-right */
                    displace = 10;
                case(200): /* right */
                {
                    *x += displace;
                    if(_ConSetUpQpac(chanid,
                            (const struct QLRECT *)&_condetails.width,
                            _condetails.ink, _condetails.paper,
                            _condetails.border_colour, domove))
                    {
                        *x -= displace;
                    }

                    break;
                }

                case(212): /* shift-up */
                    displace = 10;
                    /* FALLTHRU */
                case(208): /* up */
                {
                    if(*y <= 0)
                    {
                        *y = 0;
                    }

                    *y -= displace;
                    if(_ConSetUpQpac(chanid,
                            (const struct QLRECT *)&_condetails.width,
                            _condetails.ink, _condetails.paper,
                            _condetails.border_colour, domove))
                    {
                        *y += displace;
                    }

                    break;
                }

                case(220): /* shift-down */
                    displace = 10;
                    /* FALLTHRU */
                case(216): /* down */
                {
                    *y += displace;

                    if(_ConSetUpQpac(chanid,
                        (const struct QLRECT *)&_condetails.width,
                        _condetails.ink, _condetails.paper,
                        _condetails.border_colour, domove))
                    {
                        *y -= displace;
                    }

                    break;
                }

                case(27):
                {
                    return(ERR_NC);
                }

                case(10):
                case(' '):
                {
                    return(0);
                }
                default:
                    break;
            } /* end switch */
        } /* end for */
    }
    else
    {
        struct  WM_prec prec;
        short           prevx;
        short           prevy;
        short           thisx;
        short           thisy;
        short           offs_x;
        short           offs_y;
        event_t         termination = ev_request |
                                      (domove ? ev_kstroke : ev_kpress);

        /* Issue the mouse pointer...                                       */

        do
        {
            /* Try to set the pointer to the upper-left-hand corner for     */
            /* move operations and the lower-right-hand corner for resize   */
            /* operations.                                                  */

            if(domove)
            {
                prevx = 0;
                prevy = 0;
            }
            else
            {
                prevx = _condetails.width;
                prevy = _condetails.height;
            }

            if(!!(qderr = iop_sptr(chanid, TIMEOUT_FOREVER, &prevx, &prevy, 1)))
            {
                return(qderr);
            }

            /* Find out the current mouse position. We did set it before,   */
            /* but just to be sure. Return immediately.                     */

            (void)iop_rptr(chanid, TIMEOUT_FOREVER, &prevx, &prevy, 
                    ev_inwin | ev_outwin, &prec);

            /* Now request the window change distance.                      */

            thisx = prevx;
            thisy = prevy;

            if(!!(qderr = iop_rptr(chanid, TIMEOUT_FOREVER, &thisx, &thisy, 
                    termination, &prec)))
            {
                return(qderr);
            }

            offs_x = (short)(thisx - prevx);
            offs_y = (short)(thisy - prevy);

            /* Even up y displacement to avoid problems with alignment.     */

            if(offs_y & 0x01)
            {
                --offs_y;
            }

            /* Handle move and resize requests.                             */

            if(domove)
            {
                _condetails.x_origin += offs_x;
                _condetails.y_origin += offs_y;

                if(_ConSetUpQpac(chanid, (const struct QLRECT *)&_condetails.width,
                        _condetails.ink, _condetails.paper,
                        _condetails.border_colour, 1))
                {
                    _condetails.x_origin -= offs_x;
                    _condetails.y_origin -= offs_y;
                }
            }
            else
            {
                _condetails.width  += offs_x;
                _condetails.height += offs_y;

                if(_ConSetUpQpac(chanid, (const struct QLRECT *)&_condetails.width,
                        _condetails.ink, _condetails.paper,
                        _condetails.border_colour, 0))
                {
                    _condetails.width  -= offs_x;
                    _condetails.height -= offs_y;
                }
            }
        } while(prec.kstk != k_do && prec.kstk != k_cancel && prec.kstk != 0x1b);
        /* Until do, cancel or escape. */

        if(prec.kstk == k_cancel || prec.kstk == 0x1b)
        {
            return(ERR_NC);
        }
    }

    return(0);
}

static void even(unsigned short *x)
{
    if(*x & 0x01)
    {
        (*x)--;
    }
}

extern void consetup_qpac(chanid_t chanid,
                          struct WINDOWDEF * condetails)
{
    even(&condetails->width);
    even(&condetails->height);
    even(&condetails->x_origin);
    even(&condetails->y_origin);

    (void)_ConSetUpQpac(chanid, (const struct QLRECT *)&condetails->width,
                       condetails->ink, condetails->paper,
                       condetails->border_colour, 0);
}

extern int consetup_qpac_move(chanid_t chanid)
{
    return(ResizeOrMove(chanid, 1));
}

extern int consetup_qpac_resize(chanid_t chanid)
{
    return(ResizeOrMove(chanid, 0));
}

extern int consetup_qpac_sleep(chanid_t chanid)
{
    auto        struct  WM_swdef    swdef;
    auto        struct  WM_prec     prec;
    auto        int                 qderr;
    auto        short               x;
    auto        short               y;
    extern      char                _prog_name[];
    extern      struct  WINDOWDEF   _condetails;
    extern      long                _def_priority;
    auto        struct  WINDOWDEF * condetails = &_condetails;

    swdef.xsize  = (INT16)(strlen(_prog_name) * 6 + 6);
    swdef.ysize  = 12;
    swdef.xorg   = -1;
    swdef.yorg   = -1;
    swdef.flag   = 0;
    swdef.borw   = 1;
    swdef.borc   = 4;
    swdef.papr   = 0;
    swdef.sprite = (void *)0;

    /* Allocate window in button frame */

    if(!!(qderr = bt_frame(chanid, &swdef)))
    {
        return(qderr);
    }

    /* Make the window pick'able by setting the priority to 126. */

    (void)mt_prior(-1, 126);

    /* Set the subwindow origin, size and border. */

    if(!!(qderr = sd_wdef(chanid, TIMEOUT_FOREVER, WHITE_M8, 1, 
            (struct QLRECT *)&swdef.xsize)))
    {
        return(qderr);
    }

    /* Write program name out. */

    if((qderr = io_sstrg(chanid, TIMEOUT_FOREVER, _prog_name, 
            (short)strlen(_prog_name))) < 0)
    {
        return(qderr);
    }

    /* Set current x and y values to be inside our window. */

    x = y = 0;

    if(!!(qderr = iop_sptr(chanid, TIMEOUT_FOREVER, &x, &y, -1)))
    {
        return(qderr);
    }

    /* Read current x and y values. These where set above, but just
       to be sure. Return immediately.                                  */

    if(!!(qderr = iop_rptr(chanid, TIMEOUT_FOREVER, &x, &y, ev_inwin | ev_outwin, &prec)))
    {
        return(qderr);
    }

    while(1)
    {
        /* Pointer is now in window and border is white. */

        /* Return on key press or pointer out window. */

        if(!!(qderr = iop_rptr(chanid, TIMEOUT_FOREVER, &x, &y,
                ev_kpress | ev_kstroke | ev_outwin, &prec)))
        {
            return(qderr);
        }

        /* Exit on key press. */

        if((prec.kstk == k_do) || (prec.kstk == k_wake) || (prec.kstk == 237))
        {
            break;
        }

        /* Set border colour to black. */

        if(!!(qderr = sd_wdef(chanid, TIMEOUT_FOREVER, BLACK_M8, 1,
                (struct QLRECT *)&swdef.xsize)))
        {
            return(qderr);
        }

        /* Pointer is now out of window. */

        /* Return on key press or pointer in window. */

        if(!!(qderr = iop_rptr(chanid, TIMEOUT_FOREVER, &x, &y,
                ev_kpress | ev_kstroke | ev_inwin, &prec)))
        {
            return(qderr);
        }

        /* Exit on key press. */

        if((prec.kstk == k_do) || (prec.kstk == k_wake) || (prec.kstk == 237))
        {
            break;
        }

        /* Set border to white. */

        if(!!(qderr = sd_wdef(chanid, TIMEOUT_FOREVER, WHITE_M8, 1,
            (struct QLRECT *)&swdef.xsize)))
        {
            return(qderr);
        }
    }

    if(!!(qderr = bt_free()))
    {
        return(qderr);
    }

    (void)mt_prior((jobid_t)-1, (unsigned char)_def_priority);

    (void)_ConSetUpQpac(chanid, (const struct QLRECT *)&condetails->width,
                condetails->ink, condetails->paper,
                condetails->border_colour, 0);

    return(0);
}


extern int consetup_qpac_poll(chanid_t chanid)
{
    auto    int             qderr;
    auto    short           x = -1;
    auto    short           y = -1;
    auto    struct  WM_prec prec;
    auto    unsigned char   key;

    /* Read pointer. Return immiately. Use io.fbyte if no PI. */

    if(!iop_rptr(chanid, TIMEOUT_FOREVER, &x, &y,
            ev_inwin | ev_outwin | ev_kpress | ev_kstroke, &prec))
    {
        key = (unsigned char) prec.kstk;
    }
    else
    {
        if(!!(qderr = io_fbyte(chanid, 0, &((unsigned char)key))))
        {
            if(qderr != ERR_NC)
            {
                return(qderr);
            }
        }
    }

    switch(key)
    {
        case(k_move):
        case(245):
            return(consetup_qpac_move(chanid));

        case(k_size):
        case(241):
            return(consetup_qpac_resize(chanid));

        case(k_sleep):
        case(233):
            return(consetup_qpac_sleep(chanid));
        default:
            break;
    }

    return(0);
}


