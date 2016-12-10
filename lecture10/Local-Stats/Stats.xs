#define PERL_NO_GET_CONTEXT
#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"
#include <Stats.h>

#include "ppport.h"

#include "const-c.inc"

MODULE = Local::Stats		PACKAGE = Local::Stats		

INCLUDE: const-xs.inc

void new(SV * class, SV * coderef)
	PPCODE:
		Stats * self;
		Newx(self, 1, Stats);
		self->coderef = newSVsv(coderef);
		self->metrics = newHV();
		XPUSHs(sv_2mortal(sv_bless(
			newRV_noinc(newSViv(PTR2IV(self))),
			gv_stashpv(SvPV_nolen(class), TRUE)
		)));
		XSRETURN(1);


void add(SV * obj, char * name, SV * value)
	PPCODE:
		Metric * metric;
		Stats * self = INT2PTR(Stats *, SvIV(SvRV(obj)));
		if(!SvNIOK(value)) Perl_croak_nocontext("value not number");

		if(!hv_exists(self->metrics, name, strlen(name))){
			Newx(metric, 1, Metric);
			metric->flags = 0;
			int count, i;

			ENTER;
			SAVETMPS;
				PUSHMARK(SP);
				XPUSHs(sv_2mortal(newSVpv(name, strlen(name))));
				PUTBACK;
				count = call_sv(self->coderef, G_ARRAY);
				SPAGAIN;
				if (count < 1) croak("not value\n");
				for(i = 0; i < count; i++){
					SV * key_sv = POPs;
					if(SvPOK(key_sv)){
						char * key = SvPV_nolen(key_sv);
						if (strEQ(key, "")) Perl_croak_nocontext("not found %s", name);
						else if (strEQ(key, "avg")) metric->flags |= F_AVG;
						else if (strEQ(key, "cnt")) metric->flags |= F_CNT;
						else if (strEQ(key, "min")) metric->flags |= F_MIN;
						else if (strEQ(key, "max")) metric->flags |= F_MAX;
						else if (strEQ(key, "sum")) metric->flags |= F_SUM;
						else croak("invalid value not metrics\n");
					} else croak("invalid value not string\n");
				}
				PUTBACK;
			FREETMPS;
			LEAVE;
			undef_metric;
		} else{
			SV * hashval = SvRV(HeVAL(hv_fetch_ent(self->metrics, sv_2mortal(newSVpv(name,strlen(name))),0,0)));
			metric = INT2PTR(Metric *, SvIV(hashval));
		}

		NV val = SvNVx(value);
		if (metric->flags & (F_CNT | F_AVG)){
			if(metric->cnt == &PL_sv_undef) metric->cnt = newSViv(1);
			else sv_setiv(metric->cnt, SvIVx(metric->cnt)+1);
		}
		if (metric->flags & (F_SUM | F_AVG)){
			if(metric->sum == &PL_sv_undef) metric->sum = newSVnv(val);
			else sv_setnv(metric->sum, SvNVx(metric->sum)+val);
		}
		if (metric->flags & F_MIN){
			if(metric->min == &PL_sv_undef) metric->min = newSVnv(val);
			else if(SvNVx(metric->min) > val) sv_setnv(metric->min, val);
		}
		if (metric->flags & F_MAX){
			if(metric->max == &PL_sv_undef) metric->max = newSVnv(val);
			else if(SvNVx(metric->max) < val) sv_setnv(metric->max, val);
		}
		if (metric->flags & F_AVG){
			if(metric->avg == &PL_sv_undef) metric->avg = newSVnv(SvNVx(metric->sum)/SvIVx(metric->cnt));
			else sv_setnv(metric->avg, SvNVx(metric->sum)/SvIVx(metric->cnt));
		}

		hv_store(self->metrics, name, strlen(name), 
				newRV_noinc(newSViv(PTR2IV(metric))), 0);
		XSRETURN(1);


void stat(SV * obj)
	PPCODE:
		HE * entry;
		I32 retlen;
		Stats * self = INT2PTR(Stats *, SvIV(SvRV(obj)));

		HV * result = newHV();
		hv_iterinit(self->metrics);
		while (entry = hv_iternext(self->metrics)){
			char * key = hv_iterkey(entry,&retlen);
			SV * hashval = SvRV(hv_iterval(self->metrics,entry));
			Metric * metric = INT2PTR(Metric *, SvIV(hashval));

			HV * h_metric = newHV();
			if (metric->flags & F_AVG) hv_store(h_metric, "avg", 3, newSVsv(metric->avg), 0);
			if (metric->flags & F_CNT) hv_store(h_metric, "cnt", 3, newSVsv(metric->cnt), 0);
			if (metric->flags & F_MIN) hv_store(h_metric, "min", 3, newSVsv(metric->min), 0);
			if (metric->flags & F_MAX) hv_store(h_metric, "max", 3, newSVsv(metric->max), 0);
			if (metric->flags & F_SUM) hv_store(h_metric, "sum", 3, newSVsv(metric->sum), 0);
			hv_store(result, key, strlen(key), newRV_noinc((SV *)h_metric), 0);

			clear_metric;
			undef_metric;
			hv_store(self->metrics, key, strlen(key), 
				newRV_noinc(newSViv(PTR2IV(metric))), 0);
		}

		XPUSHs(sv_2mortal(newRV_noinc((SV *)result)));
		XSRETURN(1);


void DESTROY(SV * obj)
	PPCODE:
		HE * entry;
		I32 retlen;
		Stats * self = INT2PTR(Stats *, SvIV(SvRV(obj)));

		hv_iterinit(self->metrics);
		while (entry = hv_iternext(self->metrics)){
			char * key = hv_iterkey(entry,&retlen);
			SV * hashval = SvRV(hv_iterval(self->metrics,entry));
			Metric * metric = INT2PTR(Metric *, SvIV(hashval));
			clear_metric;
			Safefree(metric);
		}
		SvREFCNT_dec(self->metrics);
		SvREFCNT_dec(self->coderef);
		Safefree(self);
		XSRETURN(0);

