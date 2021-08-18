#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <qdos.h>
#include <things.h>

/*
 * Demo program for c68 HOT KEYS
 *
 * free, gratis etc etc (NO WARRANTY)
 * (c) Jonathan Hudson 1993
 * v0.02 20/12/93                c68 v.4x compatible
 */

char _prog_name[] = "It's the HOTtest";

int main(void)
{
    int sts;
    HK_ITEM *h;
    char *qtxt = "QED";
    char *btxt = "wstat";
    char *jtxt = "REMark >> Another Freeware product from sunny Muscat <<\n";
    char *ttxt = "Jobs";
    short lt;
    short key,knum;
    short even;
    short extra;
    char *mykeys = "QWJj";
    char *p;
    long dummy;
    
    if((sts = hk_cjob()))
    {
        perror("Create HotJob");
        exit(sts);
    }

    /*
     * Here we set up a HOT_LOAD1 type key (QED on ALT Q)
     * c.f ert HOT_LOAD1('Q', 'qed')
     * Note the use of the HKH_GUARD structure, otherwise the
     * HOT_KEY system can't load the job when we use the hot key.
     */
 
    lt = strlen(qtxt);
    even = ((lt+1) & ~1);                   /* Make length even */
    extra = even + sizeof(HKH_GUARD);       /* plus guard size  */

    /* Allocate memory owned by system (job zero) */
    
    if((h = (HK_ITEM *) mt_alchp ((int)(sizeof(HK_HEAD) + extra), &dummy, 0)) != NULL)
    {
        HKH_GUARD *pg = (HKH_GUARD *)(h->name + even);   /* Guard pointer */
        
        /*
         * Set the guard structure to zeros. The structure contents are
         * essentially undocumented, I would hazard a guess that the items
         * xo,yo,xs,ys and brdr define 'guardian window' and the gmem
         * item defines the memory for the hot job in Kbytes ?
         *
         * We also fill in the constant items jsrl and jma6. The hk_set()
         * routine will fill in the gard item with the hotkey vector.
         */

        memset(pg, '\0', sizeof(HKH_GUARD));

        pg->jsrl = HKH_JSRL; 
        pg->jma6 = HKH_JMPA6;

	h->hd.str_len = lt;
    	h->hd.id = HK_ID;
    	h->hd.type = HKI_WKXF;
    	h->hd.ptr = NULL;
	memcpy(h->name, qtxt, lt);
    
    	sts = hk_set('Q', h, pg);
    	
    	printf("Set Q %d (%d %x)\n", sts, h, h);
    }

    /*
     * Now define a Superbasic command, Sb is picked to action
     * the command.
     * c.f. HOT_CMD('W', 'wstat');
     */

    lt = strlen(btxt);
    
    if((h = (HK_ITEM *) mt_alchp ((int)(sizeof(HK_HEAD) + lt), &dummy, 0)) != NULL)
    {
	h->hd.str_len = lt;
    	h->hd.id = HK_ID;
    	h->hd.type = HKI_CMD;
    	h->hd.ptr = strncpy(h->name, btxt, lt);
    
    	sts = hk_set('W', h, NULL);
    	
    	printf("Set W %d (%d %x)\n", sts, h, h);
    }

    /*
     * Define a command to stuff text into the keyboard queue
     * c.f. ert HOT_KEY ('J',"REMARK >> ... << ", '')
     */
     
    lt = strlen(jtxt);

    if((h = (HK_ITEM *) mt_alchp ((int)(sizeof(HK_HEAD) + lt) ,&dummy, 0)) != NULL)
    {

	h->hd.str_len = lt;
    	h->hd.id = HK_ID;
    	h->hd.type = HKI_STUF;
    	h->hd.ptr = strncpy(h->name, jtxt, lt);
    
    	sts = hk_set('J', h, NULL);
    	
    	printf("Set J %d (%d %x)\n", sts, h, h);
    }
    /*
     * Define a command to invoke QPAC2 "Jobs" thing
     * c.f. ert HOT_WAKE ('j',"Jobs")
     */
     
    lt = strlen(ttxt);

    if((h = (HK_ITEM *) mt_alchp((int)(sizeof(HK_HEAD) + lt), &dummy, 0)) != NULL)
    {

	h->hd.str_len = lt;
    	h->hd.id = HK_ID;
    	h->hd.type = HKI_XTHG;
    	h->hd.ptr = strncpy(h->name, ttxt, lt);
    
    	sts = hk_set('j', h, NULL);
    	
    	printf("Set j %d (%d %x)\n", sts, h, h);
    }

    /*
     * Now see if we can FIND and DO any of the HOT_KEYS
     */

     for(p = mykeys; *p; p++)
     {
        char kname[2];

        kname[0] = *p;
        kname[1] = '\0';
        sts = hk_fitem(kname, &h, &key, &knum);
        if(sts)
        {
            printf("%c -- %d\n", *p, sts);
        }
        else
        {
            printf("%c %.*s ... ", *p, h->hd.str_len, h->name);
            sts = hk_do(h);
            puts(sts ? "Fails" : "OK");
        }
     }
}    
