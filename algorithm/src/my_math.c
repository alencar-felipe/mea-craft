#include "my_math.h"

static fixed_t fixed_core_sin(fixed_t x);

m4_t m4_mul(m4_t *a, m4_t *b)
{
    int i, j, k;
    m4_t res;

    for (i = 0; i < 4; i++) {
        for (j = 0; j < 4; j++) {
            res.x[i][j] = 0;
            for (k = 0; k < 4; k++) {
                res.x[i][j] += fmul(a->x[i][k], b->x[k][j]);
            }
        }
    }

    return res;
}

v4_t m4_v4_mul(m4_t *a, v4_t *b)
{
    v4_t res;

    for (int i = 0; i < 4; i++) {
        res.x[i] = 0;
        for (int j = 0; j < 4; j++) {
            res.x[i] += fmul(a->x[i][j], b->x[j]);
        }
    }

    return res;
}

fixed_t fsin(fixed_t x) {
    if (x > 0) {
        return fixed_core_sin(x);
    } else {
        return -fixed_core_sin(-x);
    }
}

fixed_t fcos(fixed_t x) 
{
    return fsin(x + PI/2);
}

fixed_t fixed_core_sin(fixed_t x) 
{
    x = fdiv(x, 2*PI);    
    x &= (0xFFFFFFFF >> FIXED_BIT); // remove integer part

    if (x <= ONE/2) {
        fixed_t t = 2*fmul(x, (2*x - ONE));
        return fdiv(fmul(PI, t), fmul(PI - 4*ONE, t) - ONE);
    } else {
        fixed_t t = 2*fmul(ONE - x, ONE - 2*x);
        return -fdiv(fmul(PI, t), fmul(PI - 4*ONE, t) - ONE);
    }
}