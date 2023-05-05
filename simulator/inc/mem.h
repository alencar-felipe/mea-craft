#pragma once

#include "err.h"
#include "types.h"

#define MEM_LEN (1024)

#define MEM_READ    (0)
#define MEM_WRITE   (1)

word_t mem(ctx_t *ctx, word_t mode, word_t address, word_t *data);