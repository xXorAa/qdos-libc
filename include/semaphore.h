#ifndef _SEMAPHORE_H
#define _SEMAPHORE_H

extern int _num_sem; /* Number of semaphores - normally 20 */

#ifdef __STDC__
#define _P_(params) params
#else
#define _P_(params) ()
#endif

void initsems   _P_((void));
int  creatsem   _P_((int));
int  killsem    _P_((int));
int  getsem     _P_((int));
int  rlssem     _P_((int));
int  num_thrd   _P_((void));
long thread     _P_((int (*)(), char *, int, int, int, ));

#undef _P_

#endif
