#pragma once

#include <stdint.h>

#include "types.h"

#define SEXT(size, num) (num)
#define S(num) (num)
#define U(num) (num)

#define BIT(n, i) (n)
#define BITS(n, i, j) (n)

word_t load(int bits, mem_t mem, word_t addr);
void store(int bits, mem_t mem, word_t addr, word_t value);