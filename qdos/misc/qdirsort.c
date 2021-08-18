/*
 *					q d i r s o r t _ c
 *
 *	Routine to do the comparison of an extended directory
 *	works with sort string as described below. Used if
 *	no sort routine sent to routine below.
 *
 *	Compares D1 with D2.
 *	Returns :- 
 *			D1 > D2 	= +ve,
 *			D1 == D2	= 0,
 *			D1 < D2 	= -ve.
 *
 *	AMENDMENT HISTORY
 *	~~~~~~~~~~~~~~~~~
 *	20 Jun 93	DJW   - Removed unnecessary global definition of the variables
 *						d1, d2 and stext (these were hidden anyway by the
 *						local parameter declarations).
 */

#define _LIBRARY_SOURCE

#include <qdos.h>
#include <ctype.h>
#include <string.h>

#ifdef __STDC__
#define _P_(params) params
#else
#define _P_(params) ()
#endif

static int dir_compare	_P_(( struct DIR_LIST *, struct DIR_LIST *, char *));

#define SECS_PER_DAY (3600L*24L)
#define DSLEN 38 /* Length of directory name */
#define DOTEST( x, y)  ( (x) > (y) ? 1 : ( (x) < (y) ? -1 : 0 ))

/********************************************************
 * File containing routine to sort linked list of		*
 * extended QDOS directory structure.					*
 * Returns pointer to first of list.					*
 * Sort text is string containing :-					*
 * N,n sort on ascii name.								*
 * U,u sort on file useage. 							*
 * S,s sort on file size.								*
 * D,d sort on file date.								*
 * T,t sort on file time.								*
 * Uppercase = ascending sort, Lowercase = descending	*
 * If strlen(stext) > 1 then each sort is done in turn. *
 ********************************************************/

struct DIR_LIST *
qdir_sort _LIB_F3_(struct DIR_LIST *, list,  /* Existing linked list */ \
				   char *,			  stext, /* Sort parameters */ \
				   int, (*dcomp) _P_((struct DIR_LIST *, struct DIR_LIST *,char *)))/* Compare routine */
{
	struct DIR_LIST **pp;
	struct DIR_LIST *p;
	struct DIR_LIST *temp;
	struct DIR_LIST *first;

	/* Ensure we have a compare routine */
	if( dcomp == NULL ) {
		dcomp = dir_compare;
	}
	first = (struct DIR_LIST *)NULL; /* New list to create */
	while( list ) {
		/* Add each member of the old list in turn */
		/* Calculate the position to insert */
		for( p = first, pp = &first; ((*dcomp)( list, p, stext)) > 0;
				pp = &p->dl_next, p = p->dl_next);
		/* If we should insert at the start of the list - modify first pointer */
		if( p == first )
			first = list;
		temp = list->dl_next;
		list->dl_next = p;
		*pp = list;
		list = temp;
	}
	return first;
}

/*
 *	Local default comparison routine
 */
static int dir_compare _LIB_F3_(struct DIR_LIST *, d1, \
								struct DIR_LIST *, d2, \
								char *, 		   stext)
{
	char d1s[DSLEN], d2s[DSLEN];
	unsigned char *p;
	unsigned long val1, val2;
	int ret;

	if( !d2 )
		return -1; /* d1 is always less than NULL */
	switch( *stext ) {
		case 'U': /* Sort on file type */
		case 'u':
			ret = DOTEST( d1->dl_dir.d_type, d2->dl_dir.d_type);
			break;
		case 'S': /* Sort on file size */
		case 's':
			ret = DOTEST( d1->dl_dir.d_length, d2->dl_dir.d_length);
			break;
		case 'D': /* Sort on date */
		case 'd':
			val1 = d1->dl_dir.d_update / SECS_PER_DAY;
			val2 = d2->dl_dir.d_update / SECS_PER_DAY;
			ret = DOTEST( val1, val2);
			break;
		case 'T': /* Sort on time */
		case 't':
			val1 = d1->dl_dir.d_update % SECS_PER_DAY;
			val2 = d2->dl_dir.d_update % SECS_PER_DAY;
			ret = DOTEST( val1, val2);
			break;
		default:
		case 'N': /* Sort on name */
		case 'n':
			for( p = (unsigned char *)qlstr_to_c( (char *)d1s,
					 (struct QLSTR *)&d1->dl_dir.d_szname) ; *p; p++)
				*p = (unsigned char)toupper(*p);
			for( p = (unsigned char *)qlstr_to_c( (char *)d2s, 
					 (struct QLSTR *)&d2->dl_dir.d_szname) ; *p; p++)
				*p = (unsigned char)toupper(*p);
			ret = strcmp( d1s, d2s);
			break;
	}
	if( ret && islower( *stext ))
		ret = ( ret > 0 ? -1 : 1);
	return ( ret ? ret : dir_compare( d1, d2, ++stext) );
}

#undef _P_
