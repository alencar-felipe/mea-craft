#pragma once

#include <stdint.h>

#include "types.h"

#define PI ((fixed_t) (3.14159265359 * ONE))

#define MIN(a, b) ((a < b) ? (a) : (b))
#define MAX(a, b) ((a > b) ? (a) : (b))

m4_t m4_mul(m4_t *a, m4_t *b);
v4_t m4_v4_mul(m4_t *a, v4_t *b);

fixed_t fsin(fixed_t x);
fixed_t fcos(fixed_t x);

inline fixed_t fmul(fixed_t a, fixed_t b)
{
    return (a * b) / ONE;
}

inline fixed_t fdiv(fixed_t a, fixed_t b)
{
    return (ONE * a) / b;
}

