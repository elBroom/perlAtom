#define PERL_NO_GET_CONTEXT
#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

#include "ppport.h"

#include "const-c.inc"

typedef struct{
	SV* coderef;
	HV * params;
} Stats;

MODULE = Local::Stats		PACKAGE = Local::Stats		

INCLUDE: const-xs.inc

void new(SV * class, SV * coderef)
	PPCODE:
		Stats * self = (Stats *) malloc(sizeof(Stats));
		self->coderef = newSVsv(coderef);
		self->params = newHV();
		XPUSHs(sv_2mortal(sv_bless(
			newRV_noinc(newSViv(PTR2IV(self))),
			gv_stashpv(SvPV_nolen(class), TRUE)
		)));
		XSRETURN(1);

void add(SV * obj, char * name, SV * value)
	PPCODE:
		SV * obj_sv = SvROK(obj) ? SvRV(obj) : obj;
		Stats * self = INT2PTR(Stats *, SvIV(obj_sv));


void stat(SV * obj)
	PPCODE:
		SV * obj_sv = SvROK(obj) ? SvRV(obj) : obj;
		Stats * self = INT2PTR(Stats *, SvIV(obj_sv));
		XPUSHs(sv_2mortal(newRV_noinc((SV *)self->params)));
		XSRETURN(1);
