#pragma once

#include "error.h"
#include "types.h"

#define REGISTER_FILE_LEN (32)

word_t register_file(
    word_t read_address_a,
    word_t *read_data_a,
    word_t read_address_b,
    word_t *read_data_b,
    word_t write_address,
    word_t write_data,
    word_t write_enable,
    word_t *data
);