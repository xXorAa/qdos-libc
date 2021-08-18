;
;	w a i t
;
; routine to emulate the unix wait() call. process stops
; until one of its child processes exits, or returns -1
; if there are no active child processes.
; returns process id of child that exited, plus exit code
; if address is passed for it.
;
; Equivalent to C routine:
;
;		jobid_t   wait (int * ret_code)
;
; AMENDMENT HISTORY
; ~~~~~~~~~~~~~~~~~
;	07 Nov 93	DJW   - Added underscore to entry point
;
;	16 Nov 93	DJW   - Used a5 instead of a6 for link purposes
;
;	11 Apr 94	EAJ   - Reworked completely. __waitforjob also
;						used by _frkex
;
;	22 Dec 94	EAJ   - Reworked somewhat, to be compatible with SMSQ
;

;
; __waittable will point to a table holding pairs of (jobid/error_code).
; The end of the table is indicated by the jobid -1. The jobid 0 indicates
; an empty table-entry. (Job 0 will never terminate, so it is OK)
;
; The table is read regularly by wait() and waitfor(), and is filled by
; small jobs set up to wait for the actual jobs we want to wait for
;

	.bss
	.globl __waittable
__waittable:
	.space 4

	.text
	.even
	.globl _wait
	.globl __waitforjob


waitjob:	; will be set up to wait for job "d7", and will receive the exit code in d0
	movea.l __waittable,a0	;where to store jobid/exit code
	move.l	a0,d1
	beq wjq

l1: cmpi.l	#-1,(a0)		;... end ?
	beq wjq 		;yes, not room in table
	cmp.l	(a0),d7 		;... already marked?
	beq wjq 		;yes
	tst.l	(a0)			;... free entry?
	beq f1				;yes
	addq.l	#8,a0			;examine next table entry
	bra l1
f1: move.l	d7,(a0) 		;store job id
	move.l	d0,4(a0)		;and exit code

wjq:						;all done
	moveq.l #5,d0
	moveq.l #-1,d1
	moveq.l #0,d3
	trap	#1

setup:	; set up a job to wait for job "d7"
	movem.l d0/d1/d2/d3/d4/d5/d6/d7/a0/a1/a2/a3/a4/a5,-(a7)

	moveq.l #1,d0				;create job
	moveq.l #-1,d1
	moveq.l #16,d2
	move.l	#512,d3
	lea waitjob,a1
	trap	#1
	tst.l	d0
	bne sq

	move.l	#$4afb0004,6(a0)	;set up flag and name (wait)
	move.l	#$77616974,10(a0)

	suba.w	#$68,a0

	lea waitjob,a1

	move.l	a1,$62(a0)			;pc
	move.l	d7,$3c(a0)			;d7
	move.b	#127,$13(a0)		;priority increment
	move.w	#-2,$14(a0) 	;waiting for another job

	move.l	d1,d6				;job id of wait job

	moveq.l #2,d0				;get control area of job to wait for
	move.l	d7,d1
	moveq.l #0,d2
	trap	#1
	suba.w	#$68,a0

	st		$17(a0) 			;set it up so it will signal the wait job
	move.l	d6,$18(a0)

sq: movem.l (a7)+,d0/d1/d2/d3/d4/d5/d6/d7/a0/a1/a2/a3/a4/a5
	rts



;	The following routine actually performs the neccesary actions
;	to make sure that the "error code" returned by the specified
;	job, will be caught, and placed in the table, along with the
;	job-id, so wait() and waitfor() can get the information.


;	void _waitforjob(jobid_t jobid)
__waitforjob:
	link	a5,#0
	movem.l d2-d7/a2-a4,-(a7)

	tst.l	__waittable 	;is waittable ok ?
	bne wtok

	moveq.l #$18,d0 			;no, set it up
	move.l	#2056,d1
	moveq.l #-1,d2
	trap	#1
	tst.l	d0
	bne wfq
	move.l	a0,__waittable

	move.w	#255,d0 			;initialise table
l2: clr.l	(a0)+
	clr.l	(a0)+
n2: dbf 	d0,l2
	move.l	#-1,(a0)+			;end markers
	move.l	#-1,(a0)+

wtok:

	moveq.l #0,d0
	trap	#1

	move.l	d1,d7
	move.l	a0,a4

	moveq.l #2,d0				;we only want to wait on jobs owned by ourselves
	move.l	8(a5),d1
	move.l	d7,d2
	trap	#1
	tst.l	d0
	bne wfq
	cmp.l	d7,d2
	bne wfq

	suba.w	#$68,a0 			;wait job ?
	lea waitjob,a1
	cmpa.l	$62(a0),a1
	beq wfq
	tst.b	$17(a0) 			;already someone waiting ?
	bne wfq

	move.l	8(a5),d7
	bsr setup

wfq:
	movem.l (a7)+,d2-d7/a2-a4
	unlk	a5
	rts


_wait:
	link	a5,#0
	movem.l d2-d7/a2-a4,-(a7)

	moveq.l #0,d0
	trap	#1
	move.l	d1,d7


	move.l	d7,d5				;scan job tree
	moveq.l #0,d4				;no. of jobs found

	trap	#0

l3: moveq	#2,d0
	move.l	d5,d1
	move.l	d7,d2
	trap	#1
	move.l	d1,d5
	beq e3
	move.l	d5,-(a7)
	bsr __waitforjob		;request exitcode for this job
	addq.l	#4,a7
	addq.l	#1,d4
	bra l3
e3:
	and.w	#$dfff,sr

	tst.l	__waittable 	;table not set up yet ?
	beq err 			;yes, error, we will never get any answers then

l4: moveq	#8,d0				;wait a bit
	moveq.l #-1,d1
	moveq.l #10,d3
	suba.l	a1,a1
	trap	#1

	move.w	sr,d7
	trap	#0					;scan table
	move.l	__waittable,a0
l5: cmpi.l	#-1,(a0)
	beq notf
	tst.l	(a0)
	bne found
	addq.l	#8,a0
	bra l5

notf:							;nothing in table!
	move.w	d7,sr
	tst.l	d4					;any jobs in tree ?
	bne l4					;yes, try again, waiting for one to exit
err:
	moveq	#-1,d0				;no, return -1
	bra wq

found:
	move.l	(a0),d0 			;get job id
	move.l	4(a0),d1
	clr.l	(a0)				;clear table entry
	move.w	d7,sr

	move.l	8(a5),d2			;get pointer to ret_code
	beq wq					;none, exit now
	move.l	d2,a0
	move.l	d1,(a0)

wq: movem.l (a7)+,d2-d7/a2-a4
	unlk	a5
	rts
