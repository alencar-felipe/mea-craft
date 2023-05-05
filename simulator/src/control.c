#include "control.h"

word_t control(ctx_t *ctx)
{
    word_t ret = ERROR_OK;
    word_t inst;
    word_t opcode;
    word_t r1, d1;
    word_t r2, d2;
    word_t r3, d3;
    word_t f3, f7;
    word_t tmp;

    inst = 0;
    for(int i = 0; i < 4; i++) {
        mem(ctx, MEM_READ, ctx->pc + i, &tmp);
        inst += (tmp << 8*i);
    }
    
    #include <stdio.h>
    printf("%#010x\n", inst);

    opcode = BITS(inst, 0, 6);

    switch(opcode) {
        // case OPCODE_LUI:
        //     break;
            
        // case OPCODE_AUIPC:
        //     break;

        // case OPCODE_JAL:
        //     break;

        // case OPCODE_JALR:
        //     break;

        // case OPCODE_BRANC:
        //     break;

        // case OPCODE_LOAD:
        //     break;

        // case OPCODE_STORE:
        //     break;

        case OPCODE_OP_IMMED:
            r1 = BITS(inst, 15, 19);
            r2 = 0;
            r3 = BITS(inst, 7, 11);
            f3 = BITS(inst, 12, 14);
            f7 = 0;

            ret = reg_file(ctx, r1, &d1, r2, &d2, r3, d3, 1);
            if(ret) break;
            ret = immed_gen(inst, &d2);
            if(ret) break;
            ret = alu(f3, f7, d1, d2, &d3);
            if(ret) break;
            ret = reg_file(ctx, r1, &d1, r2, &d2, r3, d3, 1);
            break;

        case OPCODE_OP:
            r1 = BITS(inst, 15, 19);
            r2 = BITS(inst, 20, 24);
            r3 = BITS(inst, 7, 11);
            f3 = BITS(inst, 12, 14);
            f7 = BITS(inst, 25, 31);

            ret = reg_file(ctx, r1, &d1, r2, &d2, r3, d3, 1);
            if(ret) break;
            ret = alu(f3, f7, d1, d2, &d3);
            if(ret) break;
            ret = reg_file(ctx, r1, &d1, r2, &d2, r3, d3, 1);
            break;

        // case OPCODE_FENCE:
        //     break;

        // case OPCODE_ENVIRONMENT:
        //     break;

        default:
            ret = ERROR_CONTROL;
            break;
    }

    return ret;
}