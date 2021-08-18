#ifndef _DOS_H
#define _DOS_H
/**
*
* This header file supplies information needed to interface with the
* particular operating system and C compiler being used.
*
**/

#ifndef _TYPES_H
#include <types.h>
#endif

#ifdef __STDC__
#define _P_(params) params
#else
#define _P_(params) ()
#endif

/**
*
* The following symbols specify which operating system is being used.
*
*       CPM             Any CP/M OS
*       CPM80           CP/M for Intel 8080 or Zilog Z80
*       CPM86           CP/M for Intel 8086
*       CPM68           CP/M for Motorola 68000
*       MSDOS           Microsoft's MSDOS
*
* Note: CPM will be set to 1 for any of the above.
*
*       UNIX            "Standard" UNIX
*       MIBS            General Automation's MIBS OS
*
*/

#if CPM80
#define CPM 1
#endif
#if CPM86
#define CPM 1
#endif
#if CPM68
#define CPM 1
#endif
#if MSDOS
#define CPM 1
#endif

/**
*
* The following type definitions take care of the particularly nasty
* machine dependency caused by the unspecified handling of sign extension
* in the C language.  When converting "char" to "int" some compilers
* will extend the sign, while others will not.  Both are correct, and
* the unsuspecting programmer is the loser.  For situations where it
* matters, the new type "byte" is equivalent to "unsigned char".
*
*/
#if LATTICE
typedef unsigned char byte;
#endif
#if C68
typedef unsigned char byte;
#endif

/**
*
* Miscellaneous definitions
*
*/
#define SECSIZ 128              /* disk sector size */
#if CPM
#define DMA (char *)0x80        /* disk buffer address */
#endif

/**
*
* The following structure is a File Control Block.  Operating systems
* with CPM-like characteristics use the FCB to store information about
* a file while it is open.
*
*/
#if CPM
struct FCB  {
        char fcbdrv;            /* drive code */
        char fcbnam[8];         /* file name */
        char fcbext[3];         /* file name extension */
#if MSDOS
        short fcbcb;            /* current block number */
        short fcblrs;           /* logical record size */
        long fcblfs;            /* logical file size */
        short fcbdat;           /* create/change date */
        char fcbsys[10];        /* reserved */
        char fcbcr;             /* current record number */
        long fcbrec;            /* random record number */
#else
        char fcbexn;            /* extent number */
        char fcbs1;             /* reserved */
        char fcbs2;             /* reserved */
        char fcbrc;             /* record count */
        char fcbsys[16];        /* reserved */
        char fcbcr;             /* current record number */
        short fcbrec;           /* random record number */
        char fcbovf;            /* random record overflow */
#endif
        };

#define FCBSIZ sizeof(struct FCB)
#endif

/**
*
* The following symbols define the sizes of file names and node names.
*
*/
#if CPM
#define FNSIZE 13       /* maximum file node size */
#define FMSIZE 64       /* maximum file name size */
#define FESIZE 4        /* maximum file extension size */
#else
#define FNSIZE 16       /* maximum file node size */
#define FMSIZE 64       /* maximum file name size */
#define FESIZE 4        /* maximum file extension size */
#endif


/**
*
* The following structures define the 8086 registers that are passed to
* various low-level operating system service functions.
*
*/
#if I8086
struct XREG  {
        short ax,bx,cx,dx,si,di;
        };

struct HREG  {
        byte al,ah,bl,bh,cl,ch,dl,dh;
        };

union REGS  {
        struct XREG x;
        struct HREG h;
        };

struct SREGS  {
        short es,cs,ss,ds;
        };

struct XREGS  {
        short ax,bx,cx,dx,si,di,ds,es;
        };

union REGSS  {
        struct XREGS x;
        struct HREG h;
        };

#endif


/**
*
* The following codes are returned by the low-level operating system service
* calls.  They are usually placed into _OSERR by the OS interface functions.
*
*/
#if MSDOS
#define E_FUNC 1                /* invalid function code */
#define E_FNF 2                 /* file not found */
#define E_PNF 3                 /* path not found */
#define E_NMH 4                 /* no more file handles */
#define E_ACC 5                 /* access denied */
#define E_IFH 6                 /* invalid file handle */
#define E_MCB 7                 /* memory control block problem */
#define E_MEM 8                 /* insufficient memory */
#define E_MBA 9                 /* invalid memory block address */
#define E_ENV 10                /* invalid environment */
#define E_FMT 11                /* invalid format */
#define E_IAC 12                /* invalid access code */
#define E_DATA 13               /* invalid data */
#define E_DRV 15                /* invalid drive code */
#define E_RMV 16                /* remove denied */
#define E_DEV 17                /* invalid device */
#define E_NMF 18                /* no more files */
#endif

/**
*
* This structure contains disk size information returned by the getdfs
* function.
*/
struct DISKINFO  {
        unsigned long free;    /* number of free clusters */
        unsigned long cpd;     /* clusters per drive */
        unsigned long bps;     /* bytes per sector */
        unsigned long spc;     /* sectors per cluster */
        };

/**
*
* The following structure is used by the dfind and dnext functions to
* hold file information.
*
*/
struct FILEINFO
        {
        char resv[21];    /* reserved */        
        char attr;        /* actual file attribute */
        long time;        /* file time  and date */
        long size;        /* file size in bytes */
        char name[13];    /* file name */
        };


/**
*
* The following structure appears at the beginning (low address) of
* each free memory block.
*
*/
struct MELT {
        struct MELT *fwd;       /* points to next free block */
#if SPTR
        unsigned size;          /* number of MELTs in this block */
#else
        long size;              /* number of MELTs in this block */
#endif
        };
#define MELTSIZE sizeof(struct MELT)

/**
*
* The following structure is a device header.  It is copied to _OSCED
* when a critical error occurs.
*
*/
struct DEV
        {
        long nextdev;   /* long pointer to next device */
        short attr;     /* device attributes */
        short sfunc;    /* short pointer to strategy function */
        short ifunc;    /* short pointer to interrupt function */
        char name[8];   /* device name */
        };

/**
*
* The following structure contains country-dependent information returned
* by the getcdi function.
*
*/
struct CDI2             /* DOS Version 2 format */
        {
        short fdate;    /* date/time format */
                        /* 0 => USA (h:m:s m/d/y) */
                        /* 1 => Europe (h:m:s d/m/y) */
                        /* 2 => Japan (h:m:s d:m:y) */
        char curr[2];   /* currency symbol and null */
        char sthou[2];  /* thousands separator and null */
        char sdec[2];   /* decimal separator and null */
        char resv[24];  /* reserved */
        };

struct CDI3             /* DOS Version 3 format */
        {
        short fdate;    /* date format */
                        /* 0 => USA (m d y) */
                        /* 1 => Europe (d m y) */
                        /* 2 => Japan (d m y) */
        char curr[5];   /* currency symbol, null-terminated */
        char sthou[2];  /* thousands separator and null */
        char sdec[2];   /* decimal separator and null */
        char sdate[2];  /* date separator and null */
        char stime[2];  /* time separator and null */
        char fcurr;     /* currency format */
                        /* Bit 0 => 0 if symbol precedes value */
                        /*       => 1 if symbol follows value */
                        /* Bit 1 => number of spaces between value */
                        /*          and symbol */
        char dcurr;     /* number of decimals in currency */
        char ftime;     /* time format */
                        /* Bit 0 => 0 if 12-hour clock */
                        /*       => 1 if 24-hour clock */
        long pcase;     /* far pointer to case map function */
        char sdata[2];  /* data list separator and null */
        short resv[5];  /* reserved */
        };

union CDI
        {
        struct CDI2 v2;
        struct CDI3 v3;
        };


/**
*
* Level 0 I/O services
*
**/
void     chgdta     _P_((char *));
int      chgfa      _P_((char *, int));
int      chgft      _P_((int, long));
int      dclose     _P_((int));
int      dcreat     _P_((char *, int));
int      dfind      _P_((struct FILEINFO *, char *, int));
int      dnext      _P_((struct FILEINFO *));
int      dopen      _P_((char *, int));
unsigned dread      _P_((int, char *, unsigned));
long     dseek      _P_((int, long, int));
unsigned dwrite     _P_((int, char *, unsigned));
int      getcd      _P_((int,char *));
int      getch      _P_((void));
int      getche     _P_((void));
int      getdfs     _P_((int, struct DISKINFO *));
char *   getdta     _P_((void));
int      getfa      _P_((char *));
long     getft      _P_((int));
int      kbhit      _P_((void));
int      putch      _P_((int));
int      ungetch    _P_((int));

/**
*
* Miscellaneous definitions
*
*/
int     chgclk      _P_((unsigned char *));
int     chgdsk      _P_((int));
char *  envpack     _P_((char **, char **));
int     envunpk     _P_((char *));
void    getclk      _P_((unsigned char *));
int     getdsk      _P_((void));
int     getpf       _P_((char *, char *));
int     getpfe      _P_((char *, char *));
void    movedata    _P_((unsigned, unsigned, unsigned, unsigned, unsigned));
void    onerror     _P_((int));
int     poserr      _P_((char *));

#undef _P_


#endif /* _DOS_H */

