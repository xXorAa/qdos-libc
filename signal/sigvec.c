/*
 *          s i g v e c
 *
 *  AMENDMENT HISTORY
 *  ~~~~~~~~~~~~~~~~~
 *  22 Mar 98   DJW   - The local 'noimp()' routine removed.  Now calls the
 *                      global _SigNoImp() routine (as in previous releases
 *                      of signal handling) so that it can be replaced.
 */

#include <sys/signal.h>
#include <qdos.h>

long (*_sigvec)(int, ...) = (_sigvec_t)_SigNoImp;

