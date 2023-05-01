#pragma once

#include <stdint.h>

#include "types.h"

#define SEXT(size, num) (num)
#define S(num) (num)
#define U(num) (num)

#define BIT(n, i) (n)
#define BITS(n, i, j) (n)

bus_t load(int bits, mem_t mem, bus_t addr);
void store(int bits, mem_t mem, bus_t addr, bus_t value);