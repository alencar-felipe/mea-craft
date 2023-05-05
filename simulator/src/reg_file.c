#include "reg_file.h"

word_t reg_file(
    ctx_t *ctx,
    word_t read_address_a,
    word_t *read_data_a,
    word_t read_address_b,
    word_t *read_data_b,
    word_t write_address,
    word_t write_data,
    word_t write_enable
)
{
    word_t ret = ERROR_OK;

    if(write_address < REG_FILE_LEN) {
        if(write_address) {
            ctx->reg_file[write_address] = write_data;
        }
    } else {
        ret = ERROR_REG_FILE;
    }

    // x0 is always 0, writes to it are ignored
    ctx->reg_file[0] = 0;

    if(read_address_a < REG_FILE_LEN) {
        *read_data_a = ctx->reg_file[read_address_a];
    } else {
        ret = ERROR_REG_FILE;
    }

    if(read_address_b < REG_FILE_LEN) {
        *read_data_b = ctx->reg_file[read_address_b];
    } else {
        ret = ERROR_REG_FILE;
    }

    return ret;
}