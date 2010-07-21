#include "math.h"
#include "math_private.h"

/*
 * Combined long double sin/cos
 * Hack implementation based on sincos for now
 */

void
sincosl(long double x, long double *sinlp, long double *coslp)
{
  double sind, cosd;
  sincos((double)x, &sind, &cosd);
  *sinlp = (long double)sind;
  *coslp = (long double)cosd;
}
