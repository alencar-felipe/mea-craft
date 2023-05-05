#pragma once

#include "bit_macro.h"
#include "error.h"
#include "types.h"

#define ALU_F3_ADD  (0b000)
#define ALU_F3_SL   (0b001) // shift left
#define ALU_F3_SLT  (0b010) // set less than
#define ALU_F3_SLTU (0b011) // set less than unsigned
#define ALU_F3_XOR  (0b100)
#define ALU_F3_SR   (0b101) // shift right
#define ALU_F3_OR   (0b110)
#define ALU_F3_AND  (0b111)

word_t alu(word_t f3, word_t f7, word_t a, word_t b, word_t *c);