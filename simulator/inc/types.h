#pragma once

#include <stdint.h>

#define REGS_SIZE (32)
#define MEM_SIZE (1024)

typedef uint32_t word_t;
typedef uint8_t *mem_t;

typedef struct {
    word_t pc;
    word_t regs[REGS_SIZE];
    mem_t mem;
} ctx_t;