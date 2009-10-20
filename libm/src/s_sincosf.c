/* s_cosf.c -- float version of s_cos.c.
 * Conversion to float by Ian Lance Taylor, Cygnus Support, ian@cygnus.com.
 * Optimized by Bruce D. Evans.
 */

/*
 * ====================================================
 * Copyright (C) 1993 by Sun Microsystems, Inc. All rights reserved.
 *
 * Developed at SunPro, a Sun Microsystems, Inc. business.
 * Permission to use, copy, modify, and distribute this
 * software is freely granted, provided that this notice
 * is preserved.
 * ====================================================
 */

#include "math.h"
#define	INLINE_KERNEL_COSDF
#define	INLINE_KERNEL_SINDF
#include "math_private.h"
#include "k_cosf.c"
#include "k_sinf.c"

/* Small multiples of pi/2 rounded to double precision. */
static const double
sc1pio2 = 1*M_PI_2,			/* 0x3FF921FB, 0x54442D18 */
sc2pio2 = 2*M_PI_2,			/* 0x400921FB, 0x54442D18 */
sc3pio2 = 3*M_PI_2,			/* 0x4012D97C, 0x7F3321D2 */
sc4pio2 = 4*M_PI_2;			/* 0x401921FB, 0x54442D18 */

void
sincosf(float x, float *sinp, float *cosp)
{
	float y[2];
	int32_t n, hx, ix;

	GET_FLOAT_WORD(hx,x);
	ix = hx & 0x7fffffff;

	if(ix <= 0x3f490fda) {		/* |x| ~<= pi/4 */
	    if(ix<0x39800000)		/* |x| < 2**-12 */
		    if(((int)x)==0) {
			    *sinp = x;		/* x with inexact if x != 0 */
			    *cosp = 1.0; 	/* 1 with inexact if x != 0 */
			    return;
		    }
	    *sinp = __kernel_sindf(x);
	    *cosp = __kernel_cosdf(x);
	    return;
	}
	if(ix<=0x407b53d1) {		/* |x| ~<= 5*pi/4 */
	    if(ix>0x4016cbe3) {		/* |x|  ~> 3*pi/4 */
		*sinp =  __kernel_sindf((hx > 0 ? sc2pio2 : -sc2pio2) - x);
		*cosp = -__kernel_cosdf(x + (hx > 0 ? -sc2pio2 : sc2pio2));
		return;
	    }
	    else {
		if(hx>0) {
		    *sinp = -__kernel_cosdf(x - sc3pio2);
		    *cosp =  __kernel_sindf(sc1pio2 - x);
		    return;
		}
		else {
		    *sinp = __kernel_cosdf(x + sc3pio2);
		    *cosp = __kernel_sindf(x + sc1pio2);
		    return;
		}
	    }
	}
	if(ix<=0x40e231d5) {		/* |x| ~<= 9*pi/4 */
	    if(ix>0x40afeddf) {		/* |x|  ~> 7*pi/4 */
		*sinp = __kernel_sindf(x + (hx > 0 ? -sc4pio2 : sc4pio2));
		*cosp = __kernel_cosdf(x + (hx > 0 ? -sc4pio2 : sc4pio2));
		return;
	    }
	    else {
		if(hx>0) {
		    *sinp = -__kernel_cosdf(x - sc3pio2);
		    *cosp =  __kernel_sindf(x - sc3pio2);
		}
		else {
		    *sinp = __kernel_cosdf(x + sc3pio2);
		    *cosp = __kernel_sindf(-sc3pio2 - x);
		}
	    }
	}

    /* sin/cos(Inf or NaN) is NaN */
	else if (ix>=0x7f800000) {
		*sinp = x-x;
		*cosp = x-x;
	}

    /* general argument reduction needed */
	else {
	    n = __ieee754_rem_pio2f(x,y);
	    switch(n&3) {
		case 0:
			*sinp =  __kernel_sindf((double)y[0]+y[1]);
			*cosp =  __kernel_cosdf((double)y[0]+y[1]);
			return;
		case 1:
			*sinp =  __kernel_cosdf((double)y[0]+y[1]);
			*cosp =  __kernel_sindf(-(double)y[0]-y[1]);
			return;
		case 2: 
			*sinp =  __kernel_sindf(-(double)y[0]-y[1]);
			*cosp = -__kernel_cosdf((double)y[0]+y[1]);
			return;
		default:
			*sinp = -__kernel_cosdf((double)y[0]+y[1]);
		        *cosp =  __kernel_sindf((double)y[0]+y[1]);
			return;
	    }
	}
}
