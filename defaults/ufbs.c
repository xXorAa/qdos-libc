/*
 *  Details for the initial UFB table.
 *
 *  The initial space is enough for the stdin, stdout and stderr
 *  channels which all C programs inherit.  The actual space is
 *  allocated in the _main() routine during the start-up process.
 */

#define __LIBRARY__

#include <fcntl.h>

long _nufbs = 3;

struct UFB *_ufbs;
