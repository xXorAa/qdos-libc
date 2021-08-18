/*
 *      c o n q p a c _ t e s t
 *
 *  Program to test out the consetup_qpac() routine
 */

#include <qdos.h>
#include <qptr.h>
#include <stdio.h>
#include <unistd.h>

void (*_consetup)(chanid_t) =   consetup_qpac;
char _copyright[]           =   "(c)E.Slagter, 1994";
char _prog_name[]           =   "Consetup_Qpac_Test";
char _version[]             =   "v1.1";
long _stack                 =   8192;
char *_endmsg               =   "key...";

int main(void)
{
    do
    {
        (void)fputs("* ", stdout);
        (void)sleep(0);
    }
    while(!consetup_qpac_poll(fgetchid(stdout)));

    return(0);
}

