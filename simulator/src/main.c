#include "main.h"


int main()
{
    ctx_t *ctx = (ctx_t *) malloc(sizeof(ctx_t));

    ctx->pc = 0;

    ctx->reg_file[2] = 5;
    ctx->reg_file[3] = 6;

    ((word_t *) ctx->mem)[0] = 0x06400093;

    word_t ret = control(ctx);

    printf("ret: %d\n", ret);
    printf("x1: %d\n", ctx->reg_file[1]);

    return 0;
}