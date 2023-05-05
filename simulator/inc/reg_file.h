#pragma once

#include "err.h"
#include "types.h"

#define REG_FILE_LEN (32)

word_t reg_file_read(ctx_t *ctx, word_t address, word_t *data);
word_t reg_file_write(ctx_t *ctx, word_t address, word_t data);