#pragma once

#include "bit_macro.h"
#include "err.h"
#include "types.h"

#define SEXT_SIGNED (0)
#define SEXT_UNSIGNED (1)

#define SEXT_8 (8)
#define SEXT_12 (12)
#define SEXT_16 (16)
#define SEXT_20 (20)
#define SEXT_32 (32)

word_t sext(word_t width, word_t in, word_t *out);
