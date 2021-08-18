/*
 *	test64.c
 *
 *	This program is intended to do a first level confidence check on the
 *	64 bit multiply and divide and shift support routines for C68.
 *	More detailed checks should be performed as part of a serious library
 *	test suite (such as the Plum Hall validation suite).
 */

#include <stdio.h>

char	_progname[]="Test64";
char	_version[] ="v1.0";
char	_copyright[] =	"(c) D.J.Walker, 2000";

#ifdef QDOS
#include <qdos.h>
struct	WINDOWDEF _condetails = {2,1,0,7,452,235,30,10};
void	(*_consetup)() = consetup_title;
#endif /* QDOS */

static	unsigned long results[2];

void	Xlldiv (unsigned long a1, unsigned long a2, \
				unsigned long b1, unsigned long b2, \
				unsigned long * result);

void	Xulldiv (unsigned long a1, unsigned long a2, \
				 unsigned long b1, unsigned long b2, \
				 unsigned long * result);

void	Xaslldiv (unsigned long * assigns, \
				 unsigned long b1, unsigned long b2);

void	Xasulldiv (unsigned long * assigns, \
				 unsigned long b1, unsigned long b2);

void	Xllrem (unsigned long a1, unsigned long a2, \
				unsigned long b1, unsigned long b2, \
				unsigned long * result);

void	Xullrem (unsigned long a1, unsigned long a2, \
				 unsigned long b1, unsigned long b2, \
				 unsigned long * result);

void	Xasllrem (unsigned long * assigns, \
				 unsigned long b1, unsigned long b2);

void	Xasullrem (unsigned long * assigns, \
				 unsigned long b1, unsigned long b2);


void	Xllmul (unsigned long a1, unsigned long a2, \
				unsigned long b1, unsigned long b2, \
				unsigned long * result);

void	Xllumul (unsigned long a1, unsigned long a2, \
				 unsigned long b1, unsigned long b2, \
				 unsigned long * result);

void	Xasllmul (unsigned long aassigns, \
				 unsigned long b1, unsigned long b2);

void	Xasullmul (unsigned long * assigns, \
				 unsigned long b1, unsigned long b2);

void	Xllshl (unsigned long a1, unsigned long a2, \
				long b, unsigned long * result);

void	Xullshl (unsigned long a1, unsigned long a2, \
				long b, unsigned long * result);

void	Xllshr (unsigned long a1, unsigned long a2, \
				long b, unsigned long * result);

void	Xullshr (unsigned long a1, unsigned long a2, \
				long b, unsigned long * result);

void	Xasllshl (unsigned long * assigns, long b);

void	Xasullshl (unsigned long * assigns, long b);

void	Xasllshr (unsigned long * assigns, long b);

void	Xasullshr (unsigned long * assigns, long b);

void	raw_44 (char *name,
				void *func(unsigned long *, long),
				unsigned long a1, unsigned long a2,
				long b)
{
	results[0]=a1;
	results[1]=a2;
	printf ("%s(*(0x%08.8lx 0x%08.8lx),  0x%08.8lx)=",name,a1,a2,b);
	func(&results[0],b);
	printf ("0x%08.8lx %08.8lx\n", results[0], results[1]);
	return;
}

void	raw_48 (char *name,
				void *func(unsigned long *, unsigned long, unsigned long),
				unsigned long a1, unsigned long a2,
				unsigned long b1, unsigned long b2)
{
	printf ("%s(0x%08.8lx %08.8lx, 0x%08.8lx %08.8lx)=",name,a1,a2,b1,b2);
	results[0]=a1;
	results[1]=a2;
	func(&results[0], b1,b2);
	printf ("0x%08.8lx %08.8lx\n", results[0], results[1]);
	return;
}

void	raw_84 (char *name,
				void *func(unsigned long, unsigned long, long, unsigned long *),
				unsigned long a1, unsigned long a2,
				long b)
{
	printf ("%s(0x%08.8lx %08.8lx, 0x%08.8lx)=",name,a1,a2,b);
	func(a1,a2,b, &results[0]);
	printf ("0x%08.8lx %08.8lx\n", results[0], results[1]);
	return;
}

void	raw_88 (char *name,
				void *func(unsigned long, unsigned long, unsigned long, unsigned long, unsigned long *),
				unsigned long a1, unsigned long a2,
				unsigned long b1, unsigned long b2)
{
	printf ("%s(0x%08.8lx %08.8lx, 0x%08.8lx %08.8lx)=",name,a1,a2,b1,b2);
	func(a1,a2,b1,b2, &results[0]);
	printf ("0x%08.8lx %08.8lx\n", results[0], results[1]);
	return;
}


int main(void)
{
	unsigned long long ullx, ully, ullz;
	long	llx, lly, llz;
	unsigned long ulx, uly, ulz;
	long	lx, ly, lz;
	short	sx, sy, sz;

#ifndef QDOS
	printf("\n%s %s\t\t%s\n",_progname, _version, _copyright);
#endif /* QDOS */

	printf("\n-------------- start of direct tests  -------------\n\n");
	printf("multiply\n\n");
	raw_88 (".Xllmul", Xllmul, 0x123,0x123, 0,2);
	raw_88 (".Xllmul", Xllmul, 0,2, 0x123,0x123);
	raw_88 (".Xllmul", Xllmul, 0x123,0x123, ~0,-2);
	raw_88 (".Xllmul", Xllmul, ~0,-2, 0x123,0x123);
	raw_88 (".Xllmul", Xllmul, ~0,-2, ~0x123,-0x123);
	printf("\nassign/multiply\n\n");
	raw_48 (".Xasllmul", Xasllmul, 0x123,0x123, 0,2);
	raw_48 (".Xasllmul", Xasllmul, 0,2, 0x123,0x123);
	raw_48 (".Xasllmul", Xasllmul, 0x123,0x123, ~0,-2);
	raw_48 (".Xasllmul", Xasllmul, ~0,-2, 0x123,0x123);
	raw_48 (".Xasllmul", Xasllmul, ~0,-2, ~0x123,-0x123);
	getchar();

	printf("divide\n\n");
	raw_88 (".Xlldiv", Xlldiv, 0x123,0x123, 0,0x123);
	raw_88 (".Xlldiv", Xlldiv, ~0x123,-0x123, 0,0x123);
	raw_88 (".Xlldiv", Xlldiv, 0x123,0x123, ~0,-0x123);
	raw_88 (".Xlldiv", Xlldiv, ~0x123,-0x123, ~0,-0x123);
	raw_88 (".Xlldiv", Xlldiv, 0x123,0x124, 0x123,0x0);
	raw_88 (".Xlldiv", Xlldiv, 0x246,0x12345678, 0x123,0x0);
	raw_88 (".Xlldiv", Xlldiv, 0x0,0x0, 0x0,0x1);
	raw_88 (".Xlldiv", Xlldiv, 0x0,0x0, 0x0,0x0);
#if 0
	/* Need to handle divide by zero exception */
	raw_88 (".Xlldiv", Xlldiv, 0x0,0x1, 0x0,0x0);
#endif
	printf("\nassign/divide\n\n");
	raw_48 (".Xaslldiv", Xaslldiv, 0x123,0x123, 0,0x123);
	raw_48 (".Xaslldiv", Xaslldiv, ~0x123,-0x123, 0,0x123);
	raw_48 (".Xaslldiv", Xaslldiv, 0x123,0x123, ~0,-0x123);
	raw_48 (".Xaslldiv", Xaslldiv, ~0x123,-0x123, ~0,-0x123);
	raw_48 (".Xaslldiv", Xaslldiv, 0x123,0x124, 0x123,0x0);
	raw_48 (".Xaslldiv", Xaslldiv, 0x246,0x12345678, 0x123,0x0);
	raw_48 (".Xaslldiv", Xaslldiv, 0x0,0x0,0x0,0x1);
	raw_48 (".Xaslldiv", Xaslldiv, 0x0,0x0,0x0,0x0);
	getchar();
	printf("remainder\n\n");
	raw_88 (".Xllrem", Xllrem, 0x123,0x123, 0,0x123);
	raw_88 (".Xllrem", Xllrem, 0x123,0x124, 0x123,0x0);
	raw_88 (".Xllrem", Xllrem, ~0x123,-0x124, 0x123,0x0);
	raw_88 (".Xllrem", Xllrem, 0x123,0x124, ~0x123,~0);
	raw_88 (".Xllrem", Xllrem, ~0x123,-0x124, ~0x123,~0x0);
	raw_88 (".Xllrem", Xllrem, 0x246,0x12345678, 0x123,0x0);
	raw_88 (".Xllrem", Xllrem, 0x0,0x0, 0x0,0x1);
	raw_88 (".Xllrem", Xllrem, 0x0,0x0, 0x0,0x0);
	printf("\nassign/remainder\n\n");
	raw_48 (".Xasllrem", Xasllrem, 0x123,0x123, 0,0x123);
	raw_48 (".Xasllrem", Xasllrem, 0x123,0x124, 0x123,0x0);
	raw_48 (".Xasllrem", Xasllrem, ~0x123,-0x124, 0x123,0x0);
	raw_48 (".Xasllrem", Xasllrem, 0x123,0x124, ~0x123,~0);
	raw_48 (".Xasllrem", Xasllrem, ~0x123,-0x124, ~0x123,~0);
	raw_48 (".Xasllrem", Xasllrem, 0x246,0x12345678, 0x123,0x0);
	raw_48 (".Xasllrem", Xasllrem, 0x0,0x0,0x0,0x1);
	raw_48 (".Xasllrem", Xasllrem, 0x0,0x0,0x0,0x0);
	getchar();

	printf("shifts\n\n");
	raw_84 (".Xllshl", Xllshl, 0x123,0x123, 2);
	raw_84 (".Xllshr", Xllshr, 0x123,0x123, 2);
	raw_84 (".Xllshr", Xllshr, ~0x123,~0x123, 2);
	raw_84 (".Xllshl", Xllshl, 0x123,0x123, 32);
	raw_84 (".Xllshr", Xllshr, 0x123,0x123, 32);
	raw_84 (".Xllshr", Xllshr, ~0x123,~0x123, 32);
	raw_84 (".Xllshl", Xllshl, 0x123,0x123, 34);
	raw_84 (".Xllshr", Xllshr, 0x123,0x123, 34);
	raw_84 (".Xllshr", Xllshr, ~0x123,~0x123, 34);
	raw_84 (".Xullshl", Xullshl, 0x123,0x123, 2);
	raw_84 (".Xullshr", Xullshr, 0x123,0x123, 2);
	raw_84 (".Xullshr", Xullshr, ~0x123,~0x123, 2);
	raw_84 (".Xullshl", Xullshl, 0x123,0x123, 32);
	raw_84 (".Xullshr", Xullshr, 0x123,0x123, 32);
	raw_84 (".Xullshr", Xullshr, ~0x123,~0x123, 32);
	raw_84 (".Xullshl", Xullshl, 0x123,0x123, 34);
	raw_84 (".Xullshr", Xullshr, 0x123,0x123, 34);
	raw_84 (".Xullshr", Xullshr, ~0x123,~0x123, 34);
	getchar();
	printf("assign/shifts\n\n");
	raw_44 (".Xasllshl", Xasllshl, 0x123,0x123, 2);
	raw_44 (".Xasllshr", Xasllshr, 0x123,0x123, 2);
	raw_44 (".Xasllshr", Xasllshr, ~0x123,~0x123, 2);
	raw_44 (".Xasllshl", Xasllshl, 0x123,0x123, 32);
	raw_44 (".Xasllshr", Xasllshr, 0x123,0x123, 32);
	raw_44 (".Xasllshr", Xasllshr, ~0x123,~0x123, 32);
	raw_44 (".Xasllshl", Xasllshl, 0x123,0x123, 34);
	raw_44 (".Xasllshr", Xasllshr, 0x123,0x123, 34);
	raw_44 (".Xasllshr", Xasllshr, ~0x123,~0x123, 34);
	raw_44 (".Xasullshl", Xasullshl, 0x123,0x123, 2);
	raw_44 (".Xasullshr", Xasullshr, 0x123,0x123, 2);
	raw_44 (".Xasullshr", Xasullshr, -0x123,-0x123, 2);
	raw_44 (".Xasullshl", Xasullshl, 0x123,0x123, 32);
	raw_44 (".Xasullshr", Xasullshr, 0x123,0x123, 32);
	raw_44 (".Xasullshr", Xasullshr, -0x123,-0x123, 32);
	raw_44 (".Xasullshl", Xasullshl, 0x123,0x123, 34);
	raw_44 (".Xasullshr", Xasullshr, 0x123,0x123, 34);
	raw_44 (".Xasullshr", Xasullshr, -0x123,-0x123, 34);
	getchar();
	printf("\n-------------- end of direct tests  -------------\n\n");


 #if 0

	printf("\n---------------- multiply -------------\n\n");
	lx = 3; ly = 3; lz = lx * ly;
	printf ("signed:   +3 * +3 = %ld\n", lz);
	lx = -3; ly = -3; lz = lx * ly;
	printf ("signed:   -3 * -3 = %ld\n", lz);
	lx = 3; ly = -3; lz = lx * ly;
	printf ("signed:   -3 * +3 = %ld\n", lz);
	lx = 3; ly = -3; lz = lx * ly;
	printf ("signed:   +3 * -3 = %ld\n", lz);
	ulx = 3; uly = 3; ulz = ulx * uly;
	printf ("unsigned: 3 x 3 = %ld\n", ulz);
	
	printf("\n------------ multiply (power of 2) -------------\n\n");
	lx = 3; ly = 4; lz = lx * ly;
	printf ("signed:   +3 * +4 = %ld\n", lz);
	lx = -3; ly = -4; lz = lx * ly;
	printf ("signed:   -3 * -4 = %ld\n", lz);
	lx = 3; ly = -4; lz = lx * ly;
	printf ("signed:   -3 * +4 = %ld\n", lz);
	lx = 3; ly = -4; lz = lx * ly;
	printf ("signed:   +3 * -4 = %ld\n", lz);
	ulx = 3; uly = 4; ulz = ulx * uly;
	printf ("unsigned: 3 x 4 = %ld\n", ulz);

	getchar();
	printf("\n---------------- divide -------------\n\n");
	lx = 5; ly = 3; lz = lx / ly;
	printf ("signed:   +5 / +3 = %ld\n", lz);
	lx = -5; ly = -3; lz = lx / ly;
	printf ("signed:   -5 / -3 = %ld\n", lz);
	lx = 5; ly = -3; lz = lx / ly;
	printf ("signed:   -5 / +3 = %ld\n", lz);
	lx = 5; ly = -3; lz = lx / ly;
	printf ("signed:   +5 / -3 = %ld\n", lz);
	ulx = 5; uly = 3; ulz = ulx / uly;
	printf ("unsigned: 5 / 3 = %ld\n", ulz);
	ulx = 5; uly = 3; ulz = ulx / uly;

	sx = -5; sy = -3; sz = sx / sy;
	printf ("signed short:   -5 / -3 = %d\n", sz);
	sx = 5; sy = -3; sz = sx / sy;
	printf ("signed short:   -5 / +3 = %d\n", sz);
	sx = 5; sy = -3; sz = sx / sy;
	printf ("signed short:   +5 / -3 = %d\n", sz);

	printf("\n---------------- modulus -------------\n\n");
	lx = 5; ly = 3; lz = lx % ly;
	printf ("signed:   +5 %% +3 = %ld\n", lz);
	lx = -5; ly = -3; lz = lx % ly;
	printf ("signed:   -5 %% -3 = %ld\n", lz);
	lx = -5; ly = 3; lz = lx % ly;
	printf ("signed:   -5 %% +3 = %ld\n", lz);
	lx = 5; ly = -3; lz = lx % ly;
	printf ("signed:   +5 %% -3 = %ld\n", lz);
	ulx = 5; uly = 3; ulz = ulx % uly;
	printf ("unsigned: 5 %% 3 = %ld\n", ulz);

	sx = -5; sy = -3; sz = sx % sy;
	printf ("signed short:   -5 %% -3 = %d\n", sz);
	sx = -5; sy = 3; sz = sx % sy;
	printf ("signed short:   -5 %% +3 = %d\n", sz);
	sx = 5; sy = -3; sz = sx % sy;
	printf ("signed short:   +5 %% -3 = %d\n", sz);

	getchar();
	printf("\n-------------- divide (power of 2)-------------\n\n");
	lx = 7; ly = 4; lz = lx / ly;
	printf ("signed:   +7 / +4 = %ld\n", lz);
	lx = -7; ly = -4; lz = lx / ly;
	printf ("signed:   -7 / -4 = %ld\n", lz);
	lx = 7; ly = -4; lz = lx / ly;
	printf ("signed:   -7 / +4 = %ld\n", lz);
	lx = 7; ly = -4; lz = lx / ly;
	printf ("signed:   +7 / -4 = %ld\n", lz);
	ulx = 7; uly = 4; ulz = ulx / uly;
	printf ("unsigned: 7 / 4 = %ld\n", ulz);

	sx = -7; sy = -4; sz = sx / sy;
	printf ("signed short:   -7 / -4 = %d\n", sz);
	sx = 7; sy = -4; sz = sx / sy;
	printf ("signed short:   -7 / +4 = %d\n", sz);
	sx = 7; sy = -4; sz = sx / sy;
	printf ("signed short:   +7 / -4 = %d\n", sz);

	printf("\n---------------- modulus (power of 2) -------------\n\n");
	lx = 7; ly = 4; lz = lx % ly;
	printf ("signed:   +7 %% +4 = %ld\n", lz);
	lx = -7; ly = -4; lz = lx % ly;
	printf ("signed:   -7 %% -4 = %ld\n", lz);
	lx = -7; ly = 4; lz = lx % ly;
	printf ("signed:   -7 %% +4 = %ld\n", lz);
	lx = 7; ly = -4; lz = lx % ly;
	printf ("signed:   +7 %% -4 = %ld\n", lz);
	ulx = 7; uly = 4; ulz = ulx % uly;
	printf ("unsigned: 7 %% 4 = %ld\n", ulz);

	sx = -7; sy = -4; sz = sx % sy;
	printf ("signed short:   -7 %% -4 = %d\n", sz);
	sx = -7; sy = 4; sz = sx % sy;
	printf ("signed short:   -7 %% +4 = %d\n", sz);
	sx = 7; sy = -4; sz = sx % sy;
	printf ("signed short:   +7 %% -4 = %d\n", sz);

	getchar();
	printf("\n---------------- assign multiply -------------\n\n");
	lx = 3; ly = 3; lx *= ly;
	printf ("signed:   +3 *= +3   = %ld\n", lx);
	lx = -3; ly = -3; lx *= ly;
	printf ("signed:   -3 *= -3   = %ld\n", lx);
	lx = 3; ly = -3; lx *= ly;
	printf ("signed:   -3 *= +3   = %ld\n", lx);
	lx = 3; ly = -3; lx *= ly;
	printf ("signed:   +3 *= -3   = %ld\n", lx);
	ulx = 3; uly = 3; ulx *= uly;
	printf ("unsigned: 3 *= 3     = %ld\n", ulx);
	
	printf("\n---------------- assign divide -------------\n\n");
	lx = 5; ly = 3; lx /= ly;
	printf ("signed:   +5 /= +3   = %ld\n", lx);
	lx = -5; ly = -3; lx /= ly;
	printf ("signed:   -5 /= -3   = %ld\n", lx);
	lx = -5; ly = 3; lx /= ly;
	printf ("signed:   -5 /= +3   = %ld\n", lx);
	lx = 5; ly = -3; lx /= ly;
	printf ("signed:   +5 /= -3   = %ld\n", lx);
	ulx = 5; uly = 3; ulx /= uly;
	printf ("unsigned: 5 /= 3     = %ld\n", ulx);

	printf("\n---------------- assign modulus -------------\n\n");
	lx = 5; ly = 3; lx %= ly;
	printf ("signed:   +5 %%= +3   = %ld\n", lx);
	lx = -5; ly = -3; lx %= ly;
	printf ("signed:   -5 %%= -3   = %ld\n", lx);
	lx = -5; ly = 3; lx %= ly;
	printf ("signed:   -5 %%= +3   = %ld\n", lx);
	lx = 5; ly = -3; lx %= ly;
	printf ("signed:   +5 %%= -3   = %ld\n", lx);
	ulx = 5; uly = 3; ulx %= uly;
	printf ("unsigned: 5 %%= 3     = %ld\n", ulx);
#endif

	printf("\n-------------- end of compiler tests  -------------\n\n");

	printf ("\n");
	return 0;
}
