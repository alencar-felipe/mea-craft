#include "mem.h"

word_t mem(ctx_t *ctx, word_t mode, word_t address, word_t *data)
{
    word_t ret = ERROR_OK;

    if(address < MEM_LEN) {
        if(mode == MEM_READ) {
            *data = ctx->mem[address];
        } else if(mode == MEM_WRITE) {
            ctx->mem[address] = *data;
        } else {
            ret = ERROR_MEM;
        }
    } else {
        ret = ERROR_MEM;
    }

    return ret;
}