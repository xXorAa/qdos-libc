/*
 *      s y s / l i b l i s t . h
 *
 *  This is the private header file associated 
 *  with the LIBLIST library.  It contains all
 *  the definitions that are internal to the
 *  implementation of the library (and thus
 *  should never be used by user programs).
 *
 *  The purpose of this library is to provide
 *  an object oriented method of handling list
 *  and tree structures, so that the user does
 *  not have to worry about writing such routines
 *  in all sorts of programs.
 *
 *  AMENDMENT HISTORY
 *  ~~~~~~~~~~~~~~~~~
 *  10 May 96   DJW   - First version
 *
 *  24 May 96   DJW   - Added additional definitions needed to build the
 *                      debugging version of the LIBLIST library.
 *
 *  28 May 96   DJW   - Added definitions needed to support Hash Tables
 *                      and Balanced Binary Trees.
 *                    - Changed existing internal structure definitions to
 *                      support the mechanics of the LIST_Clone method.
 *
 *  20 June 96  DJW   - Added data definitions needed to support embedding of
 *                      one lsit in another one.
 */
#ifndef _SYS_LIBLIST_H
#define _SYS_LIBLIST_H

#ifndef _LIBLIST_H
#include <liblist.h>
#endif /* _LIBLIST_H */

#include <sys/types.h>
#include <stdarg.h>
#include <assert.h>

#ifdef __STDC__
#define _P_(params) params
#else
#define _P_(params)
#endif /* __STDC__ */


#ifndef DEBUG
    /*
     *  We define our own specialist use of
     *  the library routine that supports
     *  the normal assert functionality
     */
    #define debug(routine,message,expr)  ((void) 0)
#else
    #undef debug
    /*
     *  Normal debugging enabled -
     *  this allows us to do run time checks
     *  We map this onto the 'assert' mechanism
     */
    #define _LISTSTR(x) _LISTVAL(x)
    #define _LISTVAL(x) #x
    #define debug(routine,message, expr) ((expr) ? (void)0 \
                        :  _assert( __FILE__ ":" _LISTSTR(__LINE__) "\n" \
                           routine ":" message))

#endif /* DEBUG */

typedef struct _listclass * _listclass_t;

/*
 *  Master list class definition.
 *  This will be common to all the
 *  derived classes of this generic type.
 */
struct _listmaster
    {
    size_t  sizelist;               /* Size of the list header */
    size_t  sizenode;               /* Size of the node header */
    size_t  (*count)        _P_((list_t));
    node_t  (*first)        _P_((list_t));
    node_t  (*last)         _P_((list_t));
    node_t  (*next)         _P_((list_t, node_t));
    node_t  (*previous)     _P_((list_t, node_t));
    int     (*clone)        _P_((list_t));
    node_t  (*nodenew)      _P_((list_t, va_list));
    int     (*add)          _P_((list_t, node_t));
    int     (*after)        _P_((list_t, node_t, node_t));
    int     (*remove)       _P_((list_t, node_t));
    node_t  (*find)         _P_((list_t, int (*findfunc)(node_t,va_list), va_list));
    short   typeid;
    char *  typename;
    char *  typedesc;
    };
typedef struct _listmaster * _listmaster_t;
/*
 *  possible values for the typeid field
 */
#define _LIST_SINGLE         1
#define _LIST_DOUBLE         2
#define _LIST_FIFO           4
#define _LIST_LIFO           8
#define _LIST_BTREE         16
#define _LIST_BALTREE       32
#define _LIST_HASH          64
#define _LIST_EMBED         128

/*
 *  Embedding structure
 */
struct _listembed {
        _listclass_t  outer;      /* Containing list */
        _listclass_t  inner;      /* Contained list */
    };
typedef struct _listembed * _listembed_t;

/*
 *  Generic List/Tree Class Object definition
 *  This is shared amongst all clones of this
 */
struct _listclass
    {
    struct _listmaster *master;     /* Master calss pointer */
    size_t  sizeuser;               /* Size of user part of nodes */
    int     clones;                 /* Clone count */
    int     (*initnode)_P_((node_t, va_list));  /* User node Initialise */
    int     (*killnode)_P_((node_t));           /* User node Destroy */
    int     (*compare)_P_((node_t,node_t));     /* user node compare */
    _listclass_t    linked;                     /* Linked table (if any) */
    _listembed_t    embeded;                    /* Embeded list (if any) */
    };

/*
 *  Generic List/Tree Header
 *  Object definition
 */
struct _listhead
    {
    _listclass_t  class;        /* Pointer to shared class data */
    node_t  nodes;                  /* Pointer to nodes in list */
    };

#ifndef DEBUG
#define _LIST_NODECHECK
#else
typedef struct _nodecheck {
        list_t  list;                   /* Instance of list node belongs to */
        _listclass_t type;              /* Class of list node belongs to */
        } * _nodecheck_t;

#define _LIST_NODECHECK    struct _nodecheck   check;
#endif /* DEBUG */
/*
 *  Single linked lists definitions
 */
    /*  nodes */
typedef struct _list1
    {
        _LIST_NODECHECK
        struct _list1 * next;
    } * _list1_t;

    /*  header */
typedef struct _list1h
    {
        _listclass_t    class;
        _list1_t        nodes;
    } * _list1h_t;


/*
 *  Generic Double linked list definitions
 */
    /* nodes */
typedef struct _list2
    {
        _LIST_NODECHECK
        struct _list2 * next;
        struct _list2 * prev;
    } * _list2_t;

    /* header */
typedef struct _list2h
    {
        _listclass_t    class;
        _list2_t        nodes;
        _list2_t        last;
    } * _list2h_t;

/*
 *  Generic FIFO (queue) node definition
 */
    /* nodes */
typedef struct _fifo
    {
        _LIST_NODECHECK
        struct _fifo * next;
    } * _fifo_t;

    /*  header */
typedef struct _fifoh
    {
        _listclass_t    class;
        _fifo_t         nodes;
        _fifo_t         last;
    } * _fifoh_t;

/*
 *  Generic LIFO (stack) node definition
 */
    /* nodes */
typedef struct _lifo
    {
        _LIST_NODECHECK
        struct _lifo * next;
    } * _lifo_t;

    /*  header */
typedef struct _lifoh
    {
        _listclass_t    class;
        _lifo_t         nodes;
    } * _lifoh_t;


/*
 *  Generic Binary Tree definitions
 */
    /* nodes */
typedef struct _btree
    {
        _LIST_NODECHECK
        struct  _btree *  parent;
        struct  _btree *  left;
        struct  _btree *  right;
    } * _btree_t;
    /*  header */
typedef struct _btreeh
    {
        _listclass_t    class;
        _btree_t        nodes;
    } * _btreeh_t;


/*
 *  Generic Hash table bucket definition
 */
    /* nodes */
typedef struct _hash
    {
        _LIST_NODECHECK
        list_t  linked;
    } * _hash_t;
    /*  header */
typedef struct _hashh
    {
        _listclass_t   class;
        _hash_t        nodes;
        size_t         size;       /* Number of buckets in table */
    } * _hashh_t;


/*
 *  Useful macros to convert between the type
 *  of node pointer passed to users which hides
 *  the control structures, and the internal
 *  library variants which do not.
 */
#define _LIST_USERNODE(l,n)  ((node_t)((char *)n + l->class->master->sizenode))
#define _LIST_REALNODE(l,n)  ((node_t)((char *)n - l->class->master->sizenode))

/*
 *  Globally visible functions that
 *  are internal to the implementation
 *  of the LIBLIST library.
 */
list_t  _LIST_Clone         _P_((_listclass_t));
node_t  _LIST_NewNode       _P_((list_t, va_list));
size_t  _LIST_ListCount     _P_((list_t));
int     _LIST_Index         _P_((list_t, node_t));
node_t  _LIST_FifoLast      _P_((list_t));
int     _LIST_FifoAfter     _P_((list_t,node_t,node_t));
int     _LIST_FifoRemove    _P_((list_t, node_t));
node_t  _LIST_LifoLast      _P_((list_t));
node_t  _LIST_LifoPrevious  _P_((list_t,node_t));
int     _LIST_LifoAfter     _P_((list_t,node_t,node_t));
int     _LIST_LifoRemove    _P_((list_t, node_t));
node_t  _LIST_ListFirst     _P_((list_t));
node_t  _LIST_ListNext      _P_((list_t,node_t));
int     _LIST_ListAdd       _P_((list_t,node_t));
node_t  _LIST_ListFind      _P_((list_t,int (*)(node_t,va_list),va_list));
node_t  _LIST_BtreeFirst    _P_((list_t));
node_t  _LIST_BtreeLast     _P_((list_t));
node_t  _LIST_BtreeNext     _P_((list_t, node_t));
node_t  _LIST_BtreePrevious _P_((list_t, node_t));
int     _LIST_BtreeRemove   _P_((list_t, node_t));
node_t  _LIST_BtreeFind     _P_((list_t, int (*)(node_t, va_list),va_list));
node_t  _LIST_HashFirst     _P_((list_t));
node_t  _LIST_HashLast      _P_((list_t));
node_t  _LIST_HashPrevious  _P_((list_t, node_t));
node_t  _LIST_HashNext      _P_((list_t, node_t));
int     _LIST_HashAfter     _P_((list_t, node_t, node_t));
int     _LIST_HashAdd       _P_((list_t, node_t));
int     _LIST_HashRemove    _P_((list_t, node_t));
node_t  _LIST_HashFind      _P_((list_t, int (*)(node_t, va_list),va_list));

int     _LIST_ListType      _P_((list_t));
int     _LIST_ListId        _P_((list_t, node_t));


#endif /* _SYS_LIBLIST_H */

