#pragma once

#include "bit_macros.h"
#include "error.h"
#include "types.h"

#define ALU_OR (0b000)
#define ALU_AND (0b001)
#define ALU_XOR (0b010)
#define ALU_ADD (0b100)
#define ALU_SUB (0b101)
#define ALU_LESS_THAN_SIGNED (0b110)
#define ALU_LESS_THAN_UNSIGNED (0b111)

word_t alu(word_t op, word_t a, word_t b, word_t *c);