/*
 *
 */

#include <signal.h>
#include <stdio.h>


void _SigNoImp(void)
{
    (void) printf("\n******* calling noimp ******\n");
}

