/*
 * Test / Demo for the Thing part of the hotstuff library
 *
 * The first time the program is run, it create a shared data thing
 * called "Test Stuff".
 *
 * The second time it's run, it USEs "Test Stuff", then creates a child
 * job that modifies the shared data, lists the jobs using the data
 * and then tidies up, removing the shared thing.
 *
 * v0.02 20/12/93                c68 v.4x compatible
 * v0.03 06/04/95                Works with (fixed) c68 libc routines
 */

#include <stdio.h>
#include <stdlib.h>
#include <stddef.h>             /* for offsetof */
#include <string.h>
#include <sms.h>
#include <things.h>

char _prog_name[] = "It's a fine, fine Thing";

extern char *_sys_var;

/*
 * We use this structure to describe the our shared data thing
 * the flag and type fields are mandatory QJump fields. We have
 * 32 bytes for our data (this is a trivial example :-)
 */

extern 	jcall(int (*)(), char *, int, int, int);

typedef struct
{
    THING_HEADER hd;
    char text[32];
} TEST_DATA;

typedef union {
    char _chrs[4];
    long _lng;
} ALIGN;

ALIGN Test_ID = {"0.03"};
ALIGN ThingID = {THH_FLAG};

/*
 * Let's just have one of these
 */
 
static char *Stuff = "Test Stuff";

/*
 * Here we define our simple thing
 */
 
int AddThing(char *name, char *txt, THING_LINKAGE **p)
{
    int m,n;
    int size;
    int sts;
    long dummy;
    
    n = strlen(name);

    /*
     * size = size of a linkage block plus the length of the name, and is
     * rounded to the next even number if necessary
     * DON'T USE sizeof(THING_LINKAGE) - Its not what you want
     */
     
    size = offsetof(THING_LINKAGE, th_name_text) + ((n + 1) & ~1);

    /*
     * Make one allocation for both linkage block and data
     * Owned by job zero, so it says when the program terminates
     * If the linkage is owned by the job, QDOS will tidy up for us 
     */
     
    *p = (THING_LINKAGE *) sms_achp ((m = (size + sizeof(TEST_DATA))), &dummy, 0);

    printf("Length is %d, size %d request %d\n", n ,size, m);

    if(*p)
    {
        /*
         * Got some memory, so define our thing. We have to set the id
         * the name (and length) and thing address in the linkage block
         * and the header info in the thing itself. We also preset the
         * data in the thing.
         */
         
        (*p)->th_name = n;
        memcpy((*p)->th_name_text, name, n);
        (*p)->th_verid = Test_ID._lng;

        /*
         * This is where the thing starts.
         */
         
        (*p)->th_thing = (char *) ((char *)(*p) + size);

        *(long *) ((THING_HEADER *) (*p)->th_thing)->thh_flag = ThingID._lng;
        ((THING_HEADER *) (*p)->th_thing)->thh_type = THT_DATA;
        strcpy( ((TEST_DATA *) (*p)->th_thing)->text, txt);
        sts = sms_lthg(*p);

        if(sts != 0)
        {
            sms_rchp (*p);
            *p = NULL;
        }
    }
    return sts;
}

/*
 * Sharer is a little concurrent job that shares our thing. We synchronise
 * usage by using address [31] in the shared data as a flag.
 */ 

int Sharer(void)
{
    long vers;
    THING_LINKAGE *p = NULL;    
    TEST_DATA *q;
    int sts;
    
    /*
     * Try to use the thing
     */
     
    sts = sms_uthg (Stuff, -1, -1, NULL, NULL, &vers, &p);
    if(sts > 0)
    {
        q = (TEST_DATA *)sts;
        /*
         * OK, we can use it, so change the data
         */
        strcpy(q->text, "It's a wonderful thing");

        /*
         * Set the flag to show the data has changed
         */

        q->text[31] = 1;

        /*
         * Wait until the parent has done his (her) bit
         */

        while(q->text[31])
        {
            sms_ssjb (-1, 1, NULL);
        }

        /*
         * Tell QDOS we're done with the thing
         */

        sms_fthg(Stuff, -1, NULL, 0, NULL, NULL);

        /*
         * And also tell the parent job
         */

        q->text[31] = 1;
    }

    return 0;
}

/*
 * The real work starts here
 */

int main(int ac, char **av)
{
    THING_LINKAGE *p = NULL;    
    long vers = 0;
    int sts;
    long jid;

    
    /*
     * See if we can use the thing
     */

    sts = sms_uthg(Stuff, -1, -1, NULL, NULL, &vers, &p);

    if(sts > 0)
    {
        TEST_DATA *q;
        
        /* We already have a thing from the last invocation of the
         * program, so lets see if we can (ab)use it.
         */

        q = (TEST_DATA *)sts;
        printf("Using THING, vers is %4.4s addr %x %x\n", &vers, q, p);
       
        {
            /*
             * That was OK, so show header (THG%) and the type
             * (should be 2) and the data
             */
             
            printf("Thing Header & data is (%4.4s %d) : %s\n",
                        q->hd.thh_flag, q->hd.thh_type, q->text);

            /*
             * Set the flag so the (to be conceived) child can change
             * the data.
             */
             
            q->text[31] = 0;
        }

        /*
         * Now start the child job
         */
         
	jcall(Sharer, "Share a thing", 1, 1024, 0);

	/*
	 * Idle time while the child changes the thing
	 */
	 
	while(q->text[31] == 0)
	{
	    sms_ssjb (-1, 1, NULL);
	}

        /*
         * How see what's there
         */
         
	printf("The shared thing text is now : %s\n", q->text);

        /*
         * Now see who is using the thing (should be us and the kid)
         * We prime sms_nthu by ensuring the pointer is NULL and
         * ignoring the first returned jobid
	 *
	 * Then loop through all users, displaying Job Ids and name
	 */
	printf ("See the users of %s\n", Stuff); 
	p = NULL;
        sts = sms_nthu(Stuff, &p, &jid);

        while(p)
	{
	    short *jadr;
	    long jp;
	    
	    sms_nthu(Stuff, &p, &jid);
	    printf("The user is %08x %4d %4d ", p, jid & 0xffff, jid >> 16);

            sms_injb (&jid, &jid, &jp,  &jadr);
            if(*(jadr + 3) == (short) 0x4afb)
            {
                printf("%-.*s", *(jadr+4), (jadr+5));
            }
            else
            {
                fputs("no job name", stdout);
            }
            fputc('\n', stdout);
	}

        puts("That's all");

        /*
         * Show the child it can terminate
         */
         
        q->text[31] = 0;

        /*
         * And wait until its done (ensures we can remove the thing)
         */
         
	while(q->text[31] == 0)
	{
	    sms_ssjb (-1, 1, NULL);
	}
      
        /*
         * Tell QDOS we're done with it
         */

        sts = sms_fthg(Stuff, -1, NULL, 0, NULL, NULL);
        printf("free gives %d\n", sts);

        /*
         * Now remove this troublesome thing
         */
         
        sts = sms_rthg(Stuff);
        printf("remove gives %d\n", sts);
    }
    else if(sts == ERR_FDNF)
    {
        sts = AddThing (Stuff, "What thing is this ?", &p);
        printf("Add returns %d (%x)\n", sts, p);
    }

    if(sts == ERR_NIMP)
    {
        poserr("No Thing system");
    }
    else
    {
        char *pth;
        
        fputs("Press ENTER for list", stdout);
        getchar();

        puts("This is the nthg list");

        /* Depends on the fact that ANSI (&c68) allow free(NULL) */
        
        for (pth = NULL; sts = sms_nthg(pth, &p), free(pth), p;
                        pth = qlstr_to_c(malloc(p->th_name + 1),
                                        (struct QLSTR *) &p->th_name))
        {
            char num[16], *np;

            printf("%4d %08x", sts, p);
            if(p->th_thing)
            {
                int n;
                n = ((THING_HEADER *) p->th_thing) ->thh_type;

                /*
                 * If its not the THING thing, clear out the
                 * list bit
                 */
                
                if(n > 0)
                {
                    n = n &  ~THT_LST;
                }
                np = itoa(n, num);
            }
            else
            {
                np = "(None)";
	    }  
            /*
             * And show name and type
             */
            printf(" %-20.*s %s\n", p->th_name, p->th_name_text, np);
	}
    }
    return 0;    
}
