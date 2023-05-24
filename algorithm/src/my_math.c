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
                res.x[i][j] += a->x[i][k] * b->x[k][j];
            }
        }
    }

    return res;
}

v4_t m4_v4_mul(m4_t *a, v4_t *b) {
    v4_t res;

    for (int i = 0; i < 4; i++) {
        res.x[i] = 0;
        for (int j = 0; j < 4; j++) {
            res.x[i] += a->x[i][j] * b->x[j];
        }
    }

    return res;
}

fixed_t fixed_sin(fixed_t x) {
    if (x > 0) {
        return fixed_core_sin(x);
    } else {
        return -fixed_core_sin(-x);
    }
}

fixed_t fixed_cos(fixed_t x) {
    return fixed_sin(x + FIXED_PI/2);
}

fixed_t fixed_core_sin(fixed_t x) {
    x /= 2 * FIXED_PI;
    x -= (x >> FIXED_FRAC_BITS) << FIXED_FRAC_BITS; // remove integer part

    if (x <= 0.5) {
        fixed_t t = 2 * x * (2 * x - 1);
        return (FIXED_PI * t) / ((FIXED_PI - 4) * t - 1);
    } else {
        fixed_t t = 2 * (1 - x) * (1 - 2 * x);
        return -(FIXED_PI * t) / ((FIXED_PI - 4) * t - 1);
    }
}