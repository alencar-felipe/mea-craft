#include <stdio.h>
#include <stdlib.h>

#include "err.h"
#include "control.h"
#include "types.h"
#include "util.h"

int main()
{   
    word_t err;
    ctx_t ctx;
    byte_t *mem;
    

    mem = malloc(MEM_LEN);
    load_bin("../software/build/build.bin", mem, MEM_LEN);

    ctx.pc = 0;
    ctx.mem = mem;

    err = ERR_OK;
    while(!err) {
        err = control(&ctx);
    }
    
    printf("err: 0x%08x\n", err);
    printf("pc:  0x%08x\n", ctx.pc);
    printf("x1: %d\n", ctx.reg_file[1]);
    printf("x2: %d\n", ctx.reg_file[2]);
    printf("x3: %d\n", ctx.reg_file[3]);
    printf("x4: %d\n", ctx.reg_file[4]);
    printf("x5: %d\n", ctx.reg_file[5]);
    printf("x6: %d\n", ctx.reg_file[6]);

    return 0;
}