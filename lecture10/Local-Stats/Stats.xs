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
		Stats * self = (Stats *) malloc(sizeof(Stats));
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
		SV * obj_sv = SvROK(obj) ? SvRV(obj) : obj;
		Stats * self = INT2PTR(Stats *, SvIV(obj_sv));
		if(!hv_exists(self->metrics, name, strlen(name))){
			metric = (Metric *) malloc(sizeof(Metric));
			metric->flags = 18;
			clear_metric;
		} else{
			SV * hashval = HeVAL(hv_fetch_ent(self->metrics,newSVpv(name,strlen(name)),0,0));
			SV * hashval_sv = SvROK(hashval) ? SvRV(hashval) : hashval;
			metric = INT2PTR(Metric *, SvIV(hashval_sv));
		}

		

		hv_store(self->metrics, name, strlen(name), 
				newRV_noinc(newSViv(PTR2IV(metric))), 0);



void stat(SV * obj)
	PPCODE:
		HE * entry;
		I32 retlen;
		SV * obj_sv = SvROK(obj) ? SvRV(obj) : obj;
		Stats * self = INT2PTR(Stats *, SvIV(obj_sv));

		HV * result = newHV();
		hv_iterinit(self->metrics);
		while (entry = hv_iternext(self->metrics)){
			char * key = hv_iterkey(entry,&retlen);
			SV * hashval = hv_iterval(self->metrics,entry);
			SV * hashval_sv = SvROK(hashval) ? SvRV(hashval) : hashval;
			Metric * metric = INT2PTR(Metric *, SvIV(hashval_sv));

			HV * h_metric = newHV();
			if (metric->flags & F_AVG){
				hv_store(h_metric, "avg", 3, metric->avg, 0);
			}
			if (metric->flags & F_CNT){
				hv_store(h_metric, "cnt", 3, metric->cnt, 0);
			}
			if (metric->flags & F_MIN){
				hv_store(h_metric, "min", 3, metric->min, 0);
			}
			if (metric->flags & F_MAX){
				hv_store(h_metric, "max", 3, metric->max, 0);
			}
			if (metric->flags & F_SUM){
				hv_store(h_metric, "sum", 3, metric->sum, 0);
			}
			hv_store(result, key, strlen(key), newRV_noinc((SV *)h_metric), 0);

			clear_metric;
			hv_store(self->metrics, key, strlen(key), 
				newRV_noinc(newSViv(PTR2IV(metric))), 0);
		}

		XPUSHs(sv_2mortal(newRV_noinc((SV *)result)));
		XSRETURN(1);
