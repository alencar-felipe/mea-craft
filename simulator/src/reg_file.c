#include "reg_file.h"

word_t reg_file_read(ctx_t *ctx, word_t address, word_t *data)
{
    word_t ret = ERR_OK;

    if(address < REG_FILE_LEN) {
        *data = ctx->reg_file[address];
    } else {
        ret = ERR_REG_FILE;
    }

    return ret;
}

word_t reg_file_write(ctx_t *ctx, word_t address, word_t data)
{
    word_t ret = ERR_OK;

    if(address < REG_FILE_LEN) {
        ctx->reg_file[address] = data;
    } else {
        ret = ERR_REG_FILE;
    }

    // x0 is always 0, writes to it are ignored (but are not an sts)
    ctx->reg_file[0] = 0;

    return ret;
}