
#ifndef _LIBLIST_H
#define _LIBLIST_H
#define LIST_VERSION "1.5"
#define LIST_COPYRIGHT "LIBLIST library v1.5\n(c)1996-2000 David J Walker"
#ifndef _STDDEF_H
#include <stddef.h>
#endif
#ifndef _STDARG_H
#include <stdarg.h>
#endif
#ifndef _ERRNO_H
#include <errno.h>
#endif
#ifdef __STDC__
#define _(params) params
#else
#define _(params) ()
#endif
typedef struct _listhead * list_t;
typedef struct _listclass * listclass_t;
typedef void * node_t;
#define LIST_CLASS_SINGLE &_LISTsingle
#define LIST_CLASS_DOUBLE &_LISTdouble
#define LIST_CLASS_QUEUE &_LISTfifo
#define LIST_CLASS_FIFO &_LISTfifo
#define LIST_CLASS_STACK &_LISTlifo
#define LIST_CLASS_LIFO &_LISTlifo
#define LIST_CLASS_BTREE &_LISTbtree
#define LIST_CLASS_BALTREE &_LISTbaltree
#define LIST_CLASS_HASH &_LISThash
#ifdef __cplusplus
extern "C" {
#endif
extern struct _listclass _LISTsingle;
extern struct _listclass _LISTdouble;
extern struct _listclass _LISTfifo;
extern struct _listclass _LISTlifo;
extern struct _listclass _LISTbtree;
extern struct _listclass _LISTbaltree;
extern struct _listclass _LISThash;
extern listclass_t LIST_Class _((list_t));
extern int LIST_Type _((list_t));
extern long LIST_Count _((list_t));
extern int LIST_Ordered _((list_t));
extern int LIST_Embedded _((list_t));
extern size_t LIST_Index _((list_t,node_t node));
extern node_t LIST_First _((list_t));
extern node_t LIST_Last _((list_t));
extern node_t LIST_Next _((list_t,node_t oldnode));
extern node_t LIST_Previous _((list_t,node_t oldnode));
extern list_t LIST_Inner _((list_t));
extern list_t LIST_Outer _((list_t));
extern int LIST_Duplicates _((list_t,int flags));
extern int LIST_IsFirst _((list_t,node_t));
extern int LIST_IsLast _((list_t,node_t));
extern int LIST_IsMember _((list_t,node_t));
#define LIST_TYPE_SINGLE 1
#define LIST_TYPE_DOUBLE 2
#define LIST_TYPE_QUEUE 3
#define LIST_TYPE_FIFO 3
#define LIST_TYPE_STACK 4
#define LIST_TYPE_LIFO 4
#define LIST_TYPE_BTREE 5
#define LIST_TYPE_BALTREE 6
#define LIST_TYPE_HASH 7
#define LIST_UNORDERED 0
#define LIST_ORDERED 0x7fe1
#define LIST_ORDER_NA 0x7fe3
#define LIST_DUPLICATES_NA 0
#define LIST_DUPLICATES_ALLOW 1
#define LIST_DUPLICATES_BEFORE 2
#define LIST_DUPLICATES_AFTER 3
#define LIST_DUPLICATES_NONE 4
#define LIST_DUPLICATES_QUERY 5
#define LIST_TRUE 1
#define LIST_FALSE 0
#define LIST_ERROR_NONE 0
#define LIST_ERROR_TOP -1000
#define LIST_ERROR_BADHASH -1000
#define LIST_ERROR_BADINDEX -1001
#define LIST_ERROR_BADINIT -1002
#define LIST_ERROR_BADLIST -1003
#define LIST_ERROR_BADNODE -1004
#define LIST_ERROR_BADSIZE -1005
#define LIST_ERROR_BADTYPE -1006
#define LIST_ERROR_DUPLICATE -1007
#define LIST_ERROR_NOMEMORY -1008
#define LIST_ERROR_NOTEMPTY -1009
#define LIST_ERROR_NOTFOUND -1010
#define LIST_ERROR_NOTSETUP -1011
#define LIST_ERROR_ORDERED -1012
#define LIST_ERROR_SAMELIST -1013
#define LIST_ERROR_SEQUENCE -1014
#define LIST_ERROR_UNORDERED -1015
#define LIST_ERROR_NOTREADY -1016
#define LIST_ERROR_BASE -1016
extern list_t LIST_Create _((listclass_t,size_t,\
int (*init)(node_t,va_list),\
int (*kill)(node_t),\
int (*compare)(node_t,node_t) ));
extern list_t LIST_Clone _((list_t));
extern list_t LIST_Embed _((listclass_t,list_t *,\
int (*compare)(node_t,node_t) ));
extern int LIST_HashSetup _((list_t,size_t,\
size_t (*nodehash)(node_t),\
size_t (*findhash)(va_list),\
list_t linkedlist));
#define LIST_HASHONLY ((list_t)(1))
extern int LIST_Free _((list_t));
extern int LIST_Clear _((list_t));
extern int LIST_Destroy _((list_t *));
extern node_t LIST_NewNode _((list_t,...));
extern int LIST_FreeNode _((list_t,node_t *));
extern int LIST_Add _((list_t,node_t));
extern node_t LIST_NewAdd _((list_t,...));
extern int LIST_Insert _((list_t,node_t));
extern node_t LIST_NewInsert _((list_t,...));
extern int LIST_Append _((list_t,node_t));
extern node_t LIST_NewAppend _((list_t,...));
extern int LIST_Before _((list_t,node_t,node_t));
extern node_t LIST_NewBefore _((list_t,node_t,...));
extern int LIST_After _((list_t,node_t,node_t));
extern node_t LIST_NewAfter _((list_t,node_t,...));
extern int LIST_Remove _((list_t,node_t));
extern int LIST_Delete _((list_t,node_t *));
extern int LIST_Compare _((list_t,node_t,node_t));
extern long LIST_Enumerate _((list_t,long (*enumfunc)(node_t,va_list),...));
extern node_t LIST_Find _((list_t,int (*findfunc)(node_t,va_list),...));
extern node_t LIST_Position _((list_t,size_t));
extern int LIST_Enqueue _((list_t,node_t));
extern node_t LIST_NewEnqueue _((list_t,...));
extern node_t LIST_Dequeue _((list_t));
extern int LIST_Push _((list_t,node_t));
extern node_t LIST_NewPush _((list_t,...));
extern node_t LIST_Pop _((list_t));
extern node_t LIST_Peek _((list_t));
extern int LIST_Merge _((list_t,list_t));
extern char * LIST_NameSpace_Use _((char *));
extern void LIST_NameSpace_Free _((char **));
#ifdef __cplusplus
}
#endif
#undef _
#ifndef LISTDEBUG
#ifdef LIBLIST_MACROS
#define LIST_Append(l,n) LIST_After(l,n,NULL)
#define LIST_Enqueue(l,n) LIST_After(l,n,NULL)
#define LIST_Push(l,n) LIST_Insert (l,n)
#endif
#endif
#endif
