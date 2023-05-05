#pragma once

#define SET_BIT(val, n) ((val) |= (1 << (n)))
#define CLR_BIT(val, n) ((val) &= ~(1 << (n)))
#define TGL_BIT(val, n) ((val) ^= (1 << (n)))
#define CHK_BIT(val, n) (((val) >> (n)) & 1)

#define CLR_MASK(val, mask) ((val) &= ~(mask))
#define CHK_MASK(val, mask) (((val) & (mask)) != 0)

#define BITS(val, i, j) (((val) >> (i)) & ((1 << ((j) - (i) + 1)) - 1))
