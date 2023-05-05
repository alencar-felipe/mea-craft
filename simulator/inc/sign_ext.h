#pragma once

#include "bit_macro.h"
#include "error.h"
#include "types.h"

#define SIGN_EXT_SIGNED (0)
#define SIGN_EXT_UNSIGNED (1)

#define SIGN_EXT_8 (0)
#define SIGN_EXT_16 (1)
#define SIGN_EXT_32 (2)

word_t sign_ext(word_t op, word_t width, word_t in, word_t *out);
