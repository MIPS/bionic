#include "math.h"
#include "math_private.h"

/*
 * Combined long double sin/cos
 * Use sincos implementation
 */

void
sincosl(long double x, long double *sinlp, long double *coslp)
{
  double sind, cosd;
  sincos((double)x, &sind, &cosd);
  *sinlp = (long double)sind;
  *coslp = (long double)cosd;
}
