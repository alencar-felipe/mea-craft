#pragma once

#include <stdint.h>

typedef uint32_t word_t;
typedef uint8_t byte_t;

typedef struct {
    word_t pc;
    word_t reg_file[32];
    byte_t mem[1024];
} ctx_t;