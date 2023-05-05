#include "mem.h"

word_t mem(ctx_t *ctx, word_t mode, word_t address, word_t *data)
{
    word_t ret = ERR_OK;

    if(address < MEM_LEN) {
        if(mode == MEM_READ) {
            *data = ctx->mem[address];
        } else if(mode == MEM_WRITE) {
            ctx->mem[address] = *data;
        } else {
            ret = ERR_MEM;
        }
    } else {
        ret = ERR_MEM;
    }

    return ret;
}