/*************************************************************/
/*                                                           */
/*      This is a test program to allow the routines         */
/*      in this file to be tested.                           */
/*                                                           */
/*      Simply compile this module with -DTESTING set        */
/*                                                           */
/*************************************************************/
/*
 *  AMENDMENT HISTORY
 *  ~~~~~~~~~~~~~~~~~
 *  ?? Dec 93   EJS   - Original version developed by Eric Slagter
 *
 *  20 Dec 93   DJW   - Amended to correct some small errors, and also to
 *                      be slightly easier to use.
 *                    - Made into a free-standing program seperate from the
 *                      actual routine to be tested.
 */

#include <sys/stat.h>
#include <errno.h>
#include <stdio.h>
#include <time.h>

extern int _oserr;

extern  int main(void)
{
    char            file[100];
    struct  stat    st[1];
    long            reply;

    while(puts("Enter DEVICENAME and/or FILENAME "), gets(file))
    {
        reply = stat(file, st);
        (void)printf("stat(%s)=%ld  (errno=%d, _oserr=%d)\n", file, reply, errno, _oserr);
        if (reply)
        {
            (void)perror("stat");
            continue;
        }

        (void)printf("device = %x\n", st->st_dev);
        (void)printf("inode  = %x\n", st->st_ino);
        (void)printf("modes:");

        if(st->st_mode & S_ISUID)
            (void)printf("  suid");
        if(st->st_mode & S_ISGID)
            (void)printf("  sgid");
        if(st->st_mode & S_ISVTX)
            (void)printf("  issticky");
        (void) printf ("  owner ");
        (void) printf (st->st_mode & S_IRUSR ? "r" : ".");
        (void) printf (st->st_mode & S_IWUSR ? "w" : ".");
        (void) printf (st->st_mode & S_IXUSR ? "x" : ".");
        (void) printf ("  group ");
        (void) printf (st->st_mode & S_IRGRP ? "r" : ".");
        (void) printf (st->st_mode & S_IWGRP ? "w" : ".");
        (void) printf (st->st_mode & S_IXGRP ? "x" : ".");
        (void) printf ("  other ");
        (void) printf (st->st_mode & S_IROTH ? "r" : ".");
        (void) printf (st->st_mode & S_IWOTH ? "w" : ".");
        (void) printf (st->st_mode & S_IXOTH ? "x" : ".");
        if(S_ISREG(st->st_mode))
            (void)printf("  regular_file");
        if(S_ISDIR(st->st_mode))
            (void)printf("  directory");
        if(S_ISCHR(st->st_mode))
            (void)printf("  char_special");
        if(S_ISBLK(st->st_mode))
            (void)printf("  block_special");
        if(S_ISFIFO(st->st_mode))
            (void)printf("  pipe");
        (void) printf("\n");

        (void)printf("number of links = %d\n", st->st_nlink);
        (void)printf("uid             = %d\n", st->st_uid);
        (void)printf("gid             = %d\n", st->st_gid);
        (void)printf("rdev            = %d\n", st->st_rdev);
        (void)printf("size            = %d\n", st->st_size);
        (void)printf("atime           = %ld\t%s", st->st_atime, ctime(&st->st_atime));
        (void)printf("mtime           = %ld\t%s", st->st_mtime, ctime(&st->st_mtime));
        (void)printf("ctime           = %ld\t%s", st->st_ctime, ctime(&st->st_ctime));
        (void)printf("rtime           = %ld\t%s", st->st_rtime, ctime(&st->st_rtime));
        (void)printf("btime           = %ld\t%s", st->st_btime, ctime(&st->st_btime));
        (void)printf("datas           = %d\n", st->st_datas);
        (void)printf("blocks          = %d\n", st->st_blocks);
        (void)printf("block size      = %d\n", st->st_blksize);
        (void)printf("\n");
    }

    return(0);
}

