/*
 * This file was generated automatically by ExtUtils::ParseXS version 3.30 from the
 * contents of Stats.xs. Do not edit this file, edit Stats.xs instead.
 *
 *    ANY CHANGES MADE HERE WILL BE LOST!
 *
 */

#line 1 "Stats.xs"
#define PERL_NO_GET_CONTEXT
#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"
#include <Stats.h>

#include "ppport.h"

#include "const-c.inc"

#line 21 "Stats.c"
#ifndef PERL_UNUSED_VAR
#  define PERL_UNUSED_VAR(var) if (0) var = var
#endif

#ifndef dVAR
#  define dVAR		dNOOP
#endif


/* This stuff is not part of the API! You have been warned. */
#ifndef PERL_VERSION_DECIMAL
#  define PERL_VERSION_DECIMAL(r,v,s) (r*1000000 + v*1000 + s)
#endif
#ifndef PERL_DECIMAL_VERSION
#  define PERL_DECIMAL_VERSION \
	  PERL_VERSION_DECIMAL(PERL_REVISION,PERL_VERSION,PERL_SUBVERSION)
#endif
#ifndef PERL_VERSION_GE
#  define PERL_VERSION_GE(r,v,s) \
	  (PERL_DECIMAL_VERSION >= PERL_VERSION_DECIMAL(r,v,s))
#endif
#ifndef PERL_VERSION_LE
#  define PERL_VERSION_LE(r,v,s) \
	  (PERL_DECIMAL_VERSION <= PERL_VERSION_DECIMAL(r,v,s))
#endif

/* XS_INTERNAL is the explicit static-linkage variant of the default
 * XS macro.
 *
 * XS_EXTERNAL is the same as XS_INTERNAL except it does not include
 * "STATIC", ie. it exports XSUB symbols. You probably don't want that
 * for anything but the BOOT XSUB.
 *
 * See XSUB.h in core!
 */


/* TODO: This might be compatible further back than 5.10.0. */
#if PERL_VERSION_GE(5, 10, 0) && PERL_VERSION_LE(5, 15, 1)
#  undef XS_EXTERNAL
#  undef XS_INTERNAL
#  if defined(__CYGWIN__) && defined(USE_DYNAMIC_LOADING)
#    define XS_EXTERNAL(name) __declspec(dllexport) XSPROTO(name)
#    define XS_INTERNAL(name) STATIC XSPROTO(name)
#  endif
#  if defined(__SYMBIAN32__)
#    define XS_EXTERNAL(name) EXPORT_C XSPROTO(name)
#    define XS_INTERNAL(name) EXPORT_C STATIC XSPROTO(name)
#  endif
#  ifndef XS_EXTERNAL
#    if defined(HASATTRIBUTE_UNUSED) && !defined(__cplusplus)
#      define XS_EXTERNAL(name) void name(pTHX_ CV* cv __attribute__unused__)
#      define XS_INTERNAL(name) STATIC void name(pTHX_ CV* cv __attribute__unused__)
#    else
#      ifdef __cplusplus
#        define XS_EXTERNAL(name) extern "C" XSPROTO(name)
#        define XS_INTERNAL(name) static XSPROTO(name)
#      else
#        define XS_EXTERNAL(name) XSPROTO(name)
#        define XS_INTERNAL(name) STATIC XSPROTO(name)
#      endif
#    endif
#  endif
#endif

/* perl >= 5.10.0 && perl <= 5.15.1 */


/* The XS_EXTERNAL macro is used for functions that must not be static
 * like the boot XSUB of a module. If perl didn't have an XS_EXTERNAL
 * macro defined, the best we can do is assume XS is the same.
 * Dito for XS_INTERNAL.
 */
#ifndef XS_EXTERNAL
#  define XS_EXTERNAL(name) XS(name)
#endif
#ifndef XS_INTERNAL
#  define XS_INTERNAL(name) XS(name)
#endif

/* Now, finally, after all this mess, we want an ExtUtils::ParseXS
 * internal macro that we're free to redefine for varying linkage due
 * to the EXPORT_XSUB_SYMBOLS XS keyword. This is internal, use
 * XS_EXTERNAL(name) or XS_INTERNAL(name) in your code if you need to!
 */

#undef XS_EUPXS
#if defined(PERL_EUPXS_ALWAYS_EXPORT)
#  define XS_EUPXS(name) XS_EXTERNAL(name)
#else
   /* default to internal */
#  define XS_EUPXS(name) XS_INTERNAL(name)
#endif

#ifndef PERL_ARGS_ASSERT_CROAK_XS_USAGE
#define PERL_ARGS_ASSERT_CROAK_XS_USAGE assert(cv); assert(params)

/* prototype to pass -Wmissing-prototypes */
STATIC void
S_croak_xs_usage(const CV *const cv, const char *const params);

STATIC void
S_croak_xs_usage(const CV *const cv, const char *const params)
{
    const GV *const gv = CvGV(cv);

    PERL_ARGS_ASSERT_CROAK_XS_USAGE;

    if (gv) {
        const char *const gvname = GvNAME(gv);
        const HV *const stash = GvSTASH(gv);
        const char *const hvname = stash ? HvNAME(stash) : NULL;

        if (hvname)
	    Perl_croak_nocontext("Usage: %s::%s(%s)", hvname, gvname, params);
        else
	    Perl_croak_nocontext("Usage: %s(%s)", gvname, params);
    } else {
        /* Pants. I don't think that it should be possible to get here. */
	Perl_croak_nocontext("Usage: CODE(0x%"UVxf")(%s)", PTR2UV(cv), params);
    }
}
#undef  PERL_ARGS_ASSERT_CROAK_XS_USAGE

#define croak_xs_usage        S_croak_xs_usage

#endif

/* NOTE: the prototype of newXSproto() is different in versions of perls,
 * so we define a portable version of newXSproto()
 */
#ifdef newXS_flags
#define newXSproto_portable(name, c_impl, file, proto) newXS_flags(name, c_impl, file, proto, 0)
#else
#define newXSproto_portable(name, c_impl, file, proto) (PL_Sv=(SV*)newXS(name, c_impl, file), sv_setpv(PL_Sv, proto), (CV*)PL_Sv)
#endif /* !defined(newXS_flags) */

#if PERL_VERSION_LE(5, 21, 5)
#  define newXS_deffile(a,b) Perl_newXS(aTHX_ a,b,file)
#else
#  define newXS_deffile(a,b) Perl_newXS_deffile(aTHX_ a,b)
#endif

#line 165 "Stats.c"

/* INCLUDE:  Including 'const-xs.inc' from 'Stats.xs' */


XS_EUPXS(XS_Local__Stats_constant); /* prototype to pass -Wmissing-prototypes */
XS_EUPXS(XS_Local__Stats_constant)
{
    dVAR; dXSARGS;
    if (items != 1)
       croak_xs_usage(cv,  "sv");
    PERL_UNUSED_VAR(ax); /* -Wall */
    SP -= items;
    {
#line 4 "./const-xs.inc"
#ifdef dXSTARG
	dXSTARG; /* Faster if we have it.  */
#else
	dTARGET;
#endif
	STRLEN		len;
        int		type;
	/* IV		iv;	Uncomment this if you need to return IVs */
	/* NV		nv;	Uncomment this if you need to return NVs */
	/* const char	*pv;	Uncomment this if you need to return PVs */
#line 190 "Stats.c"
	SV *	sv = ST(0)
;
	const char *	s = SvPV(sv, len);
#line 18 "./const-xs.inc"
	type = constant(aTHX_ s, len);
      /* Return 1 or 2 items. First is error message, or undef if no error.
           Second, if present, is found value */
        switch (type) {
        case PERL_constant_NOTFOUND:
          sv =
	    sv_2mortal(newSVpvf("%s is not a valid Local::Stats macro", s));
          PUSHs(sv);
          break;
        case PERL_constant_NOTDEF:
          sv = sv_2mortal(newSVpvf(
	    "Your vendor has not defined Local::Stats macro %s, used",
				   s));
          PUSHs(sv);
          break;
	/* Uncomment this if you need to return IVs
        case PERL_constant_ISIV:
          EXTEND(SP, 1);
          PUSHs(&PL_sv_undef);
          PUSHi(iv);
          break; */
	/* Uncomment this if you need to return NOs
        case PERL_constant_ISNO:
          EXTEND(SP, 1);
          PUSHs(&PL_sv_undef);
          PUSHs(&PL_sv_no);
          break; */
	/* Uncomment this if you need to return NVs
        case PERL_constant_ISNV:
          EXTEND(SP, 1);
          PUSHs(&PL_sv_undef);
          PUSHn(nv);
          break; */
	/* Uncomment this if you need to return PVs
        case PERL_constant_ISPV:
          EXTEND(SP, 1);
          PUSHs(&PL_sv_undef);
          PUSHp(pv, strlen(pv));
          break; */
	/* Uncomment this if you need to return PVNs
        case PERL_constant_ISPVN:
          EXTEND(SP, 1);
          PUSHs(&PL_sv_undef);
          PUSHp(pv, iv);
          break; */
	/* Uncomment this if you need to return SVs
        case PERL_constant_ISSV:
          EXTEND(SP, 1);
          PUSHs(&PL_sv_undef);
          PUSHs(sv);
          break; */
	/* Uncomment this if you need to return UNDEFs
        case PERL_constant_ISUNDEF:
          break; */
	/* Uncomment this if you need to return UVs
        case PERL_constant_ISUV:
          EXTEND(SP, 1);
          PUSHs(&PL_sv_undef);
          PUSHu((UV)iv);
          break; */
	/* Uncomment this if you need to return YESs
        case PERL_constant_ISYES:
          EXTEND(SP, 1);
          PUSHs(&PL_sv_undef);
          PUSHs(&PL_sv_yes);
          break; */
        default:
          sv = sv_2mortal(newSVpvf(
	    "Unexpected return type %d while processing Local::Stats macro %s, used",
               type, s));
          PUSHs(sv);
        }
#line 267 "Stats.c"
	PUTBACK;
	return;
    }
}


/* INCLUDE: Returning to 'Stats.xs' from 'const-xs.inc' */


XS_EUPXS(XS_Local__Stats_new); /* prototype to pass -Wmissing-prototypes */
XS_EUPXS(XS_Local__Stats_new)
{
    dVAR; dXSARGS;
    if (items != 2)
       croak_xs_usage(cv,  "class, coderef");
    PERL_UNUSED_VAR(ax); /* -Wall */
    SP -= items;
    {
	SV *	class = ST(0)
;
	SV *	coderef = ST(1)
;
#line 17 "Stats.xs"
		Stats * self = (Stats *) malloc(sizeof(Stats));
		self->coderef = newSVsv(coderef);
		self->metrics = newHV();
		XPUSHs(sv_2mortal(sv_bless(
			newRV_noinc(newSViv(PTR2IV(self))),
			gv_stashpv(SvPV_nolen(class), TRUE)
		)));
		XSRETURN(1);
#line 299 "Stats.c"
	PUTBACK;
	return;
    }
}


XS_EUPXS(XS_Local__Stats_add); /* prototype to pass -Wmissing-prototypes */
XS_EUPXS(XS_Local__Stats_add)
{
    dVAR; dXSARGS;
    if (items != 3)
       croak_xs_usage(cv,  "obj, name, value");
    PERL_UNUSED_VAR(ax); /* -Wall */
    SP -= items;
    {
	SV *	obj = ST(0)
;
	char *	name = (char *)SvPV_nolen(ST(1))
;
	SV *	value = ST(2)
;
#line 28 "Stats.xs"
		Metric * metric;
		Stats * self = INT2PTR(Stats *, SvIV(SvRV(obj)));
		if(!SvNIOK(value)){
			Perl_croak_nocontext("value not number");
		}

		if(!hv_exists(self->metrics, name, strlen(name))){
			metric = (Metric *) malloc(sizeof(Metric));
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
			clear_metric;
		} else{
			SV * hashval = SvRV(HeVAL(hv_fetch_ent(self->metrics,newSVpv(name,strlen(name)),0,0)));
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
		XSRETURN(0);
#line 387 "Stats.c"
	PUTBACK;
	return;
    }
}


XS_EUPXS(XS_Local__Stats_stat); /* prototype to pass -Wmissing-prototypes */
XS_EUPXS(XS_Local__Stats_stat)
{
    dVAR; dXSARGS;
    if (items != 1)
       croak_xs_usage(cv,  "obj");
    PERL_UNUSED_VAR(ax); /* -Wall */
    SP -= items;
    {
	SV *	obj = ST(0)
;
#line 97 "Stats.xs"
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
			if (metric->flags & F_AVG) hv_store(h_metric, "avg", 3, metric->avg, 0);
			if (metric->flags & F_CNT) hv_store(h_metric, "cnt", 3, metric->cnt, 0);
			if (metric->flags & F_MIN) hv_store(h_metric, "min", 3, metric->min, 0);
			if (metric->flags & F_MAX) hv_store(h_metric, "max", 3, metric->max, 0);
			if (metric->flags & F_SUM) hv_store(h_metric, "sum", 3, metric->sum, 0);
			hv_store(result, key, strlen(key), newRV_noinc((SV *)h_metric), 0);

			clear_metric;
			hv_store(self->metrics, key, strlen(key), 
				newRV_noinc(newSViv(PTR2IV(metric))), 0);
		}

		XPUSHs(sv_2mortal(newRV_noinc((SV *)result)));
		XSRETURN(1);
#line 432 "Stats.c"
	PUTBACK;
	return;
    }
}


XS_EUPXS(XS_Local__Stats_DESTROY); /* prototype to pass -Wmissing-prototypes */
XS_EUPXS(XS_Local__Stats_DESTROY)
{
    dVAR; dXSARGS;
    if (items != 1)
       croak_xs_usage(cv,  "obj");
    PERL_UNUSED_VAR(ax); /* -Wall */
    SP -= items;
    {
	SV *	obj = ST(0)
;
#line 127 "Stats.xs"
		HE * entry;
		I32 retlen;
		Stats * self = INT2PTR(Stats *, SvIV(SvRV(obj)));

		hv_iterinit(self->metrics);
		while (entry = hv_iternext(self->metrics)){
			char * key = hv_iterkey(entry,&retlen);
			SV * hashval = SvRV(hv_iterval(self->metrics,entry));
			Metric * metric = INT2PTR(Metric *, SvIV(hashval));
			free(metric);
		}
		free(self);
		XSRETURN(0);
#line 464 "Stats.c"
	PUTBACK;
	return;
    }
}

#ifdef __cplusplus
extern "C"
#endif
XS_EXTERNAL(boot_Local__Stats); /* prototype to pass -Wmissing-prototypes */
XS_EXTERNAL(boot_Local__Stats)
{
#if PERL_VERSION_LE(5, 21, 5)
    dVAR; dXSARGS;
#else
    dVAR; dXSBOOTARGSXSAPIVERCHK;
#endif
#if (PERL_REVISION == 5 && PERL_VERSION < 9)
    char* file = __FILE__;
#else
    const char* file = __FILE__;
#endif

    PERL_UNUSED_VAR(file);

    PERL_UNUSED_VAR(cv); /* -W */
    PERL_UNUSED_VAR(items); /* -W */
#if PERL_VERSION_LE(5, 21, 5)
    XS_VERSION_BOOTCHECK;
#  ifdef XS_APIVERSION_BOOTCHECK
    XS_APIVERSION_BOOTCHECK;
#  endif
#endif

        newXS_deffile("Local::Stats::constant", XS_Local__Stats_constant);
        newXS_deffile("Local::Stats::new", XS_Local__Stats_new);
        newXS_deffile("Local::Stats::add", XS_Local__Stats_add);
        newXS_deffile("Local::Stats::stat", XS_Local__Stats_stat);
        newXS_deffile("Local::Stats::DESTROY", XS_Local__Stats_DESTROY);
#if PERL_VERSION_LE(5, 21, 5)
#  if PERL_VERSION_GE(5, 9, 0)
    if (PL_unitcheckav)
        call_list(PL_scopestack_ix, PL_unitcheckav);
#  endif
    XSRETURN_YES;
#else
    Perl_xs_boot_epilog(aTHX_ ax);
#endif
}

