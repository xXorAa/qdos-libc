/*
 *      _condetails_c
 *
 *      Default definition for console channels
 *
 *  AMENDMENT HISTORY
 *  ~~~~~~~~~~~~~~~~~
 *  09 Dec 93   DJW   - Dropped window position by 10 pixels.  This is to
 *                      leave an additional space at the the top of the screen
 *                      for QPAC style buttons.
 *
 *  14 Apr 94   EAJ   - Made nicer (cosmetic changes)
 *                      (values changed slightly by DJW)
 */

#include <qdos.h>

#define LINES   20
#define COLUMNS 80
#define BORDERW 1

struct WINDOWDEF _condetails = {
                             2,
                             BORDERW,
                             0,
                             7,
                             6*COLUMNS+4*BORDERW,
                             10*LINES+3*BORDERW+12,
                             16,
                             26
                            };


