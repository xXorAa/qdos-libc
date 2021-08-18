;/*
;                   c r t d a t a
;
;   This defines the unitialised variables that are part of
;   any standard C program.  THis module is included by the
;   various versions of the startup module.
;
;                   IMPORTANT
;                   ~~~~~~~~~
;   Note that the order of the variables in the BSS section is
;   important as it is reflected in the following structures defined
;   in sys/rll.h for internal library usage.
;
;       _StdVars
;
;   AMENDMENT HISTORY
;   ~~~~~~~~~~~~~~~~~
;   $Log: crtdata_x,v $
# Revision 4.24  1998/08/02  18:35:36  djw
# Version shipped with C68 Release 4.24
#
;
;  01 Jul 99 DJW  - Removed pointer to BSS areas as this has been moved into
;                   a known (or at least findable) location as part of
;                   support for LD v2 and RLL's
;
;----------------------------------------------------------------------*/

    .data

;   The following is an initial argc/argv stype data structure.
;   If no further C initialisation is done, then it will be
;   passed to the user program.  Alternatively it will be
;   passed to the program that completes the C initialisation.

ARGC:
    dc.l    2
ARGV:                       ; Pointer to arguments
    dc.l    ARGV_VECT
ARGV_VECT:
    dc.l    PROGNAME
    .globl  __SPorig
__SPorig:
    dc.l    0               ; Value of original stack pointer
    dc.l    0

;
;   The following table is used to pull in identity strings from
;   any standard libraries that are linked in by this code.

LIBTAB:
    dc.l    LIBC_VER
    dc.l    LIBM_VER
    dc.l    LIBDEBUG_VER
    dc.l    LIBCURSES_VER
    dc.l    LIBMALLOC_VER
    dc.l    LIBVT_VER
    dc.l    LIBLIST_VER
    dc.l    LIBSROFF_VER
    dc.l    LIBRLL_VER
    dc.l    LIBSOCKET_VER
    dc.l    __CCX_option            ; Pulls in setting of the X? option to CC

   .bss

;  This is merely a label so that we can find the start of the UDATA area.
;  For this to work, this module MUST be the first one that is
;  passed to the linker when building the user program.
;
;  For LD v1 this was also the start of the relocation area.
;  For LD v2 this is no longer necessarily true.

UDATA_START:

    .globl  __sys_var
__sys_var:                 ; System variables
    .space  4

    .globl  __SPbase
__SPbase:                  ; lowest address for stack
    .space  4

;
;   The space from here to the start of the original stack will be
;   zero filled as soon as program relocation has taken place.  The
;   variables before this point are left alone as they are set up
;   prior to the clear of the BSS area happening.

ZERO_START:

    .globl  __Jobid
__Jobid:
    .space  4

    .globl  __endchanid
__endchanid:
    .space  4

    .globl  __f_onexit
__f_onexit:
    .space  4

    .globl  _errno
_errno:
    .space  4

    .globl  __oserr
__oserr:
    .space  4

    .globl  __environ
__environ:
    dc.l    0               ; Environment array pointer

    .globl  __VENV
__VENV:
    .space  4             ; Pointer to argument string array
