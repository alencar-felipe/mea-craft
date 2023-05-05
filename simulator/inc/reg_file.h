#pragma once

#include "error.h"
#include "types.h"

#define REG_FILE_LEN (32)

word_t reg_file(
    ctx_t *ctx,
    word_t read_address_a,
    word_t *read_data_a,
    word_t read_address_b,
    word_t *read_data_b,
    word_t write_address,
    word_t write_data,
    word_t write_enable
);