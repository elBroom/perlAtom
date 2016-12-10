#define F_AVG 1 << 0
#define F_CNT 1 << 1
#define F_MAX 1 << 2
#define F_MIN 1 << 3
#define F_SUM 1 << 4

#define undef_metric \
		metric->avg = &PL_sv_undef;\
		metric->cnt = &PL_sv_undef;\
		metric->max = &PL_sv_undef;\
		metric->min = &PL_sv_undef;\
		metric->sum = &PL_sv_undef;\

#define clear_metric \
		SvREFCNT_dec(metric->avg);\
		SvREFCNT_dec(metric->cnt);\
		SvREFCNT_dec(metric->max);\
		SvREFCNT_dec(metric->min);\
		SvREFCNT_dec(metric->sum);\

typedef struct{
	int flags;
	SV * avg;
	SV * cnt;
	SV * max;
	SV * min;
	SV * sum;
} Metric;

typedef struct{
	SV* coderef;
	HV * metrics;
} Stats;