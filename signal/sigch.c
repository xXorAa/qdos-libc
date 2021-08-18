/*
 *  s i g c h 
 *
 *  Signal channel Id.
 *  This vector is used to satisfy the case when there are
 *  no signal handling routines present in the library, so
 *  the _SigInit() routine (which also contains _sigch) has
 *  not been preferentially called in.
 *
 *  AMENDMENT HISTORY
 *  ~~~~~~~~~~~~~~~~~
 */
#include <sys/signal.h>

/* 
 *  make sure it doesn't contain a valid channel by accident 
 */
chanid_t _sigch=-1;
