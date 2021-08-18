/*
 *      t e s t p r o g
 *
 *  Program for testing routines in the LIBGEN library.
 *
 *  AMENDMENT HISTORY
 *  ~~~~~~~~~~~~~~~~~
 */

#include <libgen.h>
#include <stdio.h>
#include <string.h>

char *   basenames[] = {
            "testfile",
            "_testfile",
            "win1_",
            "win1_testfile",
            "win1_testfile_",
            "win1_testfile__",
            "win1_testfile_c",
            "win1_lib_testfile",
            "win1_lib_testfile_c",
            "win1_lib__testfile_c",
            NULL
            };

int main(int argc, char * argv[])
{
    char    workbuf[128];
    char ** nameptr;
    char *  ptr;

    printf ("\ntesting basename() function\n");
    for (nameptr = basenames ; *nameptr ; nameptr++)
    {
        strcpy (workbuf,*nameptr);
        ptr = basename(workbuf);
        printf ("\tbasename(\"%s\")=\"%s\"\n",*nameptr, ptr);
    }

    printf ("\nPress a key to continue\n"); getchar();

    printf ("\ntesting dirname() function\n");
    for (nameptr = basenames ; *nameptr ; nameptr++)
    {
        strcpy (workbuf,*nameptr);
        ptr = dirname(workbuf);
        printf ("\tdirname(\"%s\")=\"%s\"\n",*nameptr, ptr);
    }
}
