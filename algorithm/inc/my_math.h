#pragma once

#include <stdint.h>

#include "types.h"

#define FIXED_FRAC_BITS (16)
#define FIXED_ONE (1 << FIXED_FRAC_BITS)
#define FIXED_PI (0x0003243F)

#define INV(n) (FIXED_ONE / n)

#define MIN(a, b) ((a < b) ? (a) : (b))
#define MAX(a, b) ((a > b) ? (a) : (b))

m4_t m4_mul(m4_t *a, m4_t *b);
v4_t m4_v4_mul(m4_t *a, v4_t *b);

fixed_t fixed_sin(fixed_t x);
fixed_t fixed_cos(fixed_t x);



