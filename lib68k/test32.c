/*
 *	test.c
 *
 *	This program is intended to do a first level confidence check
 *	on the multiply and divide support routines for C68.  More detailed
 *	checks should be performed as part of a serious library test suite.
 *	(such as the Plum Hall validation suite).
 */

#include <stdio.h>

char	_progname[]="68k Test";
char	_version[] ="v1.0";
char	_copyright[] =	"(c) D.J.Walker, 1994";

#ifdef QDOS
#include <qdos.h>
struct	WINDOWDEF _condetails = {2,1,0,7,452,235,30,10};
void	(*_consetup)() = consetup_title;
#endif /* QDOS */

static	unsigned long results[2];

long	Xldiv (long a, long b, unsigned long * result);

unsigned long Xuldiv (unsigned long a, unsigned long b, unsigned long * result);

void	Xasldiv (unsigned long * assigns, unsigned long b);

void	Xasuldiv (unsigned long * assigns, unsigned long b);

long	Xlrem (long a1, long b, unsigned long * result);

unsigned long  Xulrem (unsigned long a1, unsigned long b, unsigned long * result);

void	Xaslrem (long * assigns, long b1);

void	Xasulrem (unsigned long * assigns,	unsigned long b);


long	Xlmul (long a1, long b, unsigned long * result);

unsigned long	Xulmul (unsigned long a1, unsigned long b, unsigned long * result);

void	Xaslmul (unsigned long assigns, unsigned long b);

void	Xasulmul (unsigned long * assigns, unsigned long b);


void	raw_as4 (char *name,
				void *func(unsigned long *, long),
				unsigned long a,
				long b)
{
	results[0]=a;
	func(&results[0],b);
	printf ("%s(*(0x%08.8lx), 0x%08.8lx)=%08.8lx\n",
			name,a,b,results[0]);
	return;
}

void	raw_44 (char *name,
				void *func(unsigned long, unsigned long, unsigned long *),
				unsigned long a, unsigned long b)
{
	func(a, b, &results[0]);
	printf ("%s(0x%08.8lx, 0x%08.8lx)=0x%08.8lx\n",
			name,a,b,results[0]);
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
	printf("divide\n\n");
	raw_44 (".Xldiv", Xldiv, 0x123,2);
	raw_44 (".Xldiv", Xldiv, 2, 0x123);
	raw_44 (".Xldiv", Xldiv, 0x123, (unsigned long)-2);
	raw_44 (".Xldiv", Xldiv, (unsigned long)-2, 0x123);
	raw_44 (".Xldiv", Xldiv, 0x246,0x123);
	raw_44 (".Xuldiv", Xuldiv, 0x123,2);
	raw_44 (".Xuldiv", Xuldiv, 2, 0x123);
	raw_44 (".Xuldiv", Xuldiv, 0x123, (unsigned long)-2);
	raw_44 (".Xuldiv", Xuldiv, (unsigned long)-2, 0x123);
	raw_44 (".Xuldiv", Xuldiv, 0x246,0x123);
	getchar();
	printf("\nassign/divide\n\n");
	raw_as4 (".Xasldiv", Xasldiv, 0x123, 2);
	raw_as4 (".Xasldiv", Xasldiv, 2, 0x123);
	raw_as4 (".Xasldiv", Xasldiv, 0x123, (unsigned long)-2);
	raw_as4 (".Xasldiv", Xasldiv, (unsigned long)-2, 0x123);
	raw_as4 (".Xasldiv", Xasldiv, 0x246,0x123);
	raw_as4 (".Xasuldiv", Xasuldiv, 0x123, 2);
	raw_as4 (".Xasuldiv", Xasuldiv, 2, 0x123);
	raw_as4 (".Xasuldiv", Xasuldiv, 0x123, (unsigned long)-2);
	raw_as4 (".Xasuldiv", Xasuldiv, (unsigned long)-2, 0x123);
	raw_as4 (".Xasuldiv", Xasuldiv, 0x246,0x123);
	getchar();
	printf("remaineder\n\n");
	raw_44 (".Xlrem", Xlrem, 5,3);
	raw_44 (".Xlrem", Xlrem, 3, 5);
	raw_44 (".Xlrem", Xlrem, 5, (unsigned long)-3);
	raw_44 (".Xlrem", Xlrem, -5, (unsigned long)-3);
	raw_44 (".Xlrem", Xlrem, (unsigned long)-3, 5);
	raw_44 (".Xlrem", Xlrem, -6,-3);
	raw_44 (".Xlrem", Xlrem, -5,-3);
	raw_44 (".Xlrem", Xlrem, 6,3);
	raw_44 (".Xulrem", Xulrem, 5,3);
	raw_44 (".Xulrem", Xulrem, 3, 5);
	raw_44 (".Xulrem", Xulrem, 5, (unsigned long)-3);
	raw_44 (".Xulrem", Xulrem, (unsigned long)-3, 5);
	raw_44 (".Xulrem", Xulrem, 6,3);
	raw_44 (".Xulrem", Xulrem, -6,-3);
	raw_44 (".Xulrem", Xulrem, -5,-3);
	getchar();
	printf("\nassign/remainder\n\n");
	raw_as4 (".Xaslrem", Xaslrem, 0x123, 2);
	raw_as4 (".Xaslrem", Xaslrem, 2, 0x123);
	raw_as4 (".Xaslrem", Xaslrem, 0x123, (unsigned long)-2);
	raw_as4 (".Xaslrem", Xaslrem, (unsigned long)-2, 0x123);
	raw_as4 (".Xaslrem", Xaslrem, 0x246,0x123);
	raw_as4 (".Xasulrem", Xasulrem, 0x123, 2);
	raw_as4 (".Xasulrem", Xasulrem, 2, 0x123);
	raw_as4 (".Xasulrem", Xasulrem, 0x123, (unsigned long)-2);
	raw_as4 (".Xasulrem", Xasulrem, (unsigned long)-2, 0x123);
	raw_as4 (".Xasulrem", Xasulrem, 0x246,0x123);
	getchar();
	printf("multiply\n\n");
	raw_44 (".Xlmul", Xlmul, 0x123,2);
	raw_44 (".Xlmul", Xlmul, 2, 0x123);
	raw_44 (".Xlmul", Xlmul, 0x123, (unsigned long)-2);
	raw_44 (".Xlmul", Xlmul, (unsigned long)-2, 0x123);
	raw_44 (".Xulmul", Xulmul, 0x123,2);
	raw_44 (".Xulmul", Xulmul, 2, 0x123);
	raw_44 (".Xulmul", Xulmul, 0x123, (unsigned long)-2);
	raw_44 (".Xulmul", Xulmul, (unsigned long)-2, 0x123);
	getchar();
	printf("\nassign/multiply\n\n");
	raw_as4 (".Xaslmul", Xaslmul, 0x123, 2);
	raw_as4 (".Xaslmul", Xaslmul, 2, 0x123);
	raw_as4 (".Xaslmul", Xaslmul, 0x123, (unsigned long)-2);
	raw_as4 (".Xaslmul", Xaslmul, (unsigned long)-2, 0x123);
	raw_as4 (".Xasulmul", Xasulmul, 0x123, 2);
	raw_as4 (".Xasulmul", Xasulmul, 2, 0x123);
	raw_as4 (".Xasulmul", Xasulmul, 0x123, (unsigned long)-2);
	raw_as4 (".Xasulmul", Xasulmul, (unsigned long)-2, 0x123);
	getchar();
	printf("\n-------------- end of direct tests  -------------\n\n");


	printf("\n-------------- start of indirect tests  -------------\n\n");
	printf("\n---------------- multiply -------------\n\n");
	lx = 3; ly = 3; lz = lx * ly;
	printf ("signed long:   +3 * +3 = %ld\n", lz);
	lx = -3; ly = -3; lz = lx * ly;
	printf ("signed long:   -3 * -3 = %ld\n", lz);
	lx = 3; ly = -3; lz = lx * ly;
	printf ("signed long:   -3 * +3 = %ld\n", lz);
	lx = 3; ly = -3; lz = lx * ly;
	printf ("signed long:   +3 * -3 = %ld\n", lz);
	ulx = 3; uly = 3; ulz = ulx * uly;
	printf ("unsigned long: 3 x 3 = %ld\n", ulz);
	
	printf("\n------------ multiply (power of 2) -------------\n\n");
	lx = 3; ly = 4; lz = lx * ly;
	printf ("signed long:   +3 * +4 = %ld\n", lz);
	lx = -3; ly = -4; lz = lx * ly;
	printf ("signed long:   -3 * -4 = %ld\n", lz);
	lx = 3; ly = -4; lz = lx * ly;
	printf ("signed long:   -3 * +4 = %ld\n", lz);
	lx = 3; ly = -4; lz = lx * ly;
	printf ("signed long:   +3 * -4 = %ld\n", lz);
	ulx = 3; uly = 4; ulz = ulx * uly;
	printf ("unsigned long: 3 x 4 = %ld\n", ulz);

	getchar();
	printf("\n---------------- divide -------------\n\n");
	lx = 5; ly = 3; lz = lx / ly;
	printf ("signed long:   +5 / +3 = %ld\n", lz);
	lx = -5; ly = -3; lz = lx / ly;
	printf ("signed long:   -5 / -3 = %ld\n", lz);
	lx = 5; ly = -3; lz = lx / ly;
	printf ("signed long:   -5 / +3 = %ld\n", lz);
	lx = 5; ly = -3; lz = lx / ly;
	printf ("signed long:   +5 / -3 = %ld\n", lz);
	ulx = 5; uly = 3; ulz = ulx / uly;
	printf ("unsigned long: 5 / 3 = %ld\n", ulz);
	ulx = 5; uly = 3; ulz = ulx / uly;

	sx = -5; sy = -3; sz = sx / sy;
	printf ("signed short:   -5 / -3 = %d\n", sz);
	sx = 5; sy = -3; sz = sx / sy;
	printf ("signed short:   -5 / +3 = %d\n", sz);
	sx = 5; sy = -3; sz = sx / sy;
	printf ("signed short:   +5 / -3 = %d\n", sz);

	printf("\n---------------- remainder -------------\n\n");
	lx = 5; ly = 3; lz = lx % ly;
	printf ("signed long:   +5 %% +3 = %ld\n", lz);
	lx = -5; ly = -3; lz = lx % ly;
	printf ("signed long:   -5 %% -3 = %ld\n", lz);
	lx = -5; ly = 3; lz = lx % ly;
	printf ("signed long:   -5 %% +3 = %ld\n", lz);
	lx = 5; ly = -3; lz = lx % ly;
	printf ("signed long:   +5 %% -3 = %ld\n", lz);
	ulx = 5; uly = 3; ulz = ulx % uly;
	printf ("unsigned long: 5 %% 3 = %ld\n", ulz);

	sx = -5; sy = -3; sz = sx % sy;
	printf ("signed short:   -5 %% -3 = %d\n", sz);
	sx = -5; sy = 3; sz = sx % sy;
	printf ("signed short:   -5 %% +3 = %d\n", sz);
	sx = 5; sy = -3; sz = sx % sy;
	printf ("signed short:   +5 %% -3 = %d\n", sz);

	getchar();
	printf("\n-------------- divide (power of 2)-------------\n\n");
	lx = 7; ly = 4; lz = lx / ly;
	printf ("signed long:   +7 / +4 = %ld\n", lz);
	lx = -7; ly = -4; lz = lx / ly;
	printf ("signed long:   -7 / -4 = %ld\n", lz);
	lx = 7; ly = -4; lz = lx / ly;
	printf ("signed long:   -7 / +4 = %ld\n", lz);
	lx = 7; ly = -4; lz = lx / ly;
	printf ("signed long:   +7 / -4 = %ld\n", lz);
	ulx = 7; uly = 4; ulz = ulx / uly;
	printf ("unsigned long: 7 / 4 = %ld\n", ulz);

	sx = -7; sy = -4; sz = sx / sy;
	printf ("signed short:   -7 / -4 = %d\n", sz);
	sx = 7; sy = -4; sz = sx / sy;
	printf ("signed short:   -7 / +4 = %d\n", sz);
	sx = 7; sy = -4; sz = sx / sy;
	printf ("signed short:   +7 / -4 = %d\n", sz);

	printf("\n---------------- remainder (power of 2) -------------\n\n");
	lx = 7; ly = 4; lz = lx % ly;
	printf ("signed long:   +7 %% +4 = %ld\n", lz);
	lx = -7; ly = -4; lz = lx % ly;
	printf ("signed long:   -7 %% -4 = %ld\n", lz);
	lx = -7; ly = 4; lz = lx % ly;
	printf ("signed long:   -7 %% +4 = %ld\n", lz);
	lx = 7; ly = -4; lz = lx % ly;
	printf ("signed long:   +7 %% -4 = %ld\n", lz);
	ulx = 7; uly = 4; ulz = ulx % uly;
	printf ("unsigned long: 7 %% 4 = %ld\n", ulz);

	sx = -7; sy = -4; sz = sx % sy;
	printf ("signed short:   -7 %% -4 = %d\n", sz);
	sx = -7; sy = 4; sz = sx % sy;
	printf ("signed short:   -7 %% +4 = %d\n", sz);
	sx = 7; sy = -4; sz = sx % sy;
	printf ("signed short:   +7 %% -4 = %d\n", sz);

	getchar();
	printf("\n---------------- assign multiply -------------\n\n");
	lx = 3; ly = 3; lx *= ly;
	printf ("signed long:   +3 *= +3   = %ld\n", lx);
	lx = -3; ly = -3; lx *= ly;
	printf ("signed long:   -3 *= -3   = %ld\n", lx);
	lx = 3; ly = -3; lx *= ly;
	printf ("signed long:   -3 *= +3   = %ld\n", lx);
	lx = 3; ly = -3; lx *= ly;
	printf ("signed long:   +3 *= -3   = %ld\n", lx);
	ulx = 3; uly = 3; ulx *= uly;
	printf ("unsigned long: 3 *= 3     = %ld\n", ulx);
	
	printf("\n---------------- assign divide -------------\n\n");
	lx = 5; ly = 3; lx /= ly;
	printf ("signed long:   +5 /= +3   = %ld\n", lx);
	lx = -5; ly = -3; lx /= ly;
	printf ("signed long:   -5 /= -3   = %ld\n", lx);
	lx = -5; ly = 3; lx /= ly;
	printf ("signed long:   -5 /= +3   = %ld\n", lx);
	lx = 5; ly = -3; lx /= ly;
	printf ("signed long:   +5 /= -3   = %ld\n", lx);
	ulx = 5; uly = 3; ulx /= uly;
	printf ("unsigned long: 5 /= 3     = %ld\n", ulx);

	printf("\n---------------- assign remainder -------------\n\n");
	lx = 5; ly = 3; lx %= ly;
	printf ("signed long:   +5 %%= +3   = %ld\n", lx);
	lx = -5; ly = -3; lx %= ly;
	printf ("signed long:   -5 %%= -3   = %ld\n", lx);
	lx = -5; ly = 3; lx %= ly;
	printf ("signed long:   -5 %%= +3   = %ld\n", lx);
	lx = 5; ly = -3; lx %= ly;
	printf ("signed long:   +5 %%= -3   = %ld\n", lx);
	ulx = 5; uly = 3; ulx %= uly;
	printf ("unsigned long: 5 %%= 3     = %ld\n", ulx);

	getchar();
	printf("\n-------------- end of indirect tests  -------------\n\n");
	printf ("\n");
	return 0;
}
