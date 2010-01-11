#include "math.h"
#include "math_private.h"

/*
 * Combined sin/cos
 * See s_sin.c/s_cos.c for method
 */

void
sincos(double x, double *sinp, double *cosp)
{
	double y[2],z=0.0;
	int32_t n, ix;

    /* High word of x. */
	GET_HIGH_WORD(ix,x);

    /* |x| ~< pi/4 */
	ix &= 0x7fffffff;
	if(ix <= 0x3fe921fb) {
	    if(ix<0x3e400000)			/* if x < 2**-27 */
	       if(((int)x)==0) {		/* generate inexact */
		       *sinp = x;
		       *cosp = 1.0;
		       return;
	       }
	    *sinp = __kernel_sin(x,z,0);
	    *cosp = __kernel_cos(x,z);
	    return;
	}

    /* sin/cos(Inf or NaN) is NaN */
	else if (ix>=0x7ff00000) {
		*cosp = x-x;
		*sinp = x-x;
		return;
	}

    /* argument reduction needed */
	else {
	    n = __ieee754_rem_pio2(x,y);
	    switch(n&3) {
		case 0:
			*sinp =  __kernel_sin(y[0],y[1],1);
			*cosp =  __kernel_cos(y[0],y[1]);
			return;
		case 1:
			*sinp =  __kernel_cos(y[0],y[1]);
			*cosp = -__kernel_sin(y[0],y[1],1);
			return;
		case 2:
			*sinp = -__kernel_sin(y[0],y[1],1);
			*cosp = -__kernel_cos(y[0],y[1]);
			return;
		default:
			*sinp = -__kernel_cos(y[0],y[1]);
		        *cosp =  __kernel_sin(y[0],y[1],1);
			return;
	    }
	}
}
