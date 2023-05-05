#include "control.h"

word_t control(ctx_t *ctx)
{
    word_t ret = ERR_OK;
    word_t inst;
    word_t opcode;
    word_t immed;
    word_t rd, dd;
    word_t rs1, d1;
    word_t rs2, d2;
    word_t f3, f7;
    word_t tmp;

    inst = 0;
    for(int i = 0; i < 4; i++) {
        mem(ctx, MEM_READ, ctx->pc + i, &tmp);
        inst += (tmp << 8*i);
    }
    opcode = BITS(inst, 0, 6);

    switch(opcode) {
        case OPCODE_LUI:
            rd = BITS(inst, 7, 11);
            ret = immed_gen(inst, &immed);
            if(ret) break;
            immed = immed << 12;
            ret = sext(SEXT_20, immed, &dd);
            if(ret) break;
            ret = reg_file_write(ctx, rd, dd);
            break;
            
        case OPCODE_AUIPC:
            rd = BITS(inst, 7, 11);
            d1 = ctx->pc;
            f3 = 0;
            f7 = 0;
            ret = immed_gen(inst, &immed);
            if(ret) break;
            immed = immed << 12;
            ret = sext(SEXT_20, immed, &d2);
            if(ret) break;
            ret = alu(f3, f7, d1, d2, &dd);
            if(ret) break;
            ret = reg_file_write(ctx, rd, dd);
            break;

        //case OPCODE_JAL:
        //     break;

        // case OPCODE_JALR:
        //     break;

        // case OPCODE_BRANCH:
        //     break;

        // case OPCODE_LOAD:
        //     break;

        // case OPCODE_STORE:
        //     break;

        case OPCODE_OP_IMMED:
            rd = BITS(inst, 7, 11);
            f3 = BITS(inst, 12, 14);
            rs1 = BITS(inst, 15, 19);
            f7 = 0;
            ret = reg_file_read(ctx, rs1, &d1);
            if(ret) break;
            ret = immed_gen(inst, &immed);
            if(ret) break;
            ret = alu(f3, f7, d1, immed, &dd);
            if(ret) break;
            ret = reg_file_write(ctx, rd, dd);
            break;

        case OPCODE_OP:
            rd = BITS(inst, 7, 11);
            f3 = BITS(inst, 12, 14);
            rs1 = BITS(inst, 15, 19);
            rs2 = BITS(inst, 20, 24);
            f7 = BITS(inst, 25, 31);
            ret = reg_file_read(ctx, rs1, &d1);
            if(ret) break;
            ret = reg_file_read(ctx, rs2, &d2);
            if(ret) break;
            ret = alu(f3, f7, d1, d2, &dd);
            if(ret) break;
            ret = reg_file_write(ctx, rd, dd);
            break;

        // case OPCODE_FENCE:
        //     break;

        case OPCODE_ENV:
            if(CHK_BIT(inst, 20)) {
                ret = ERR_BREAK;
            } else {
                ret = ERR_CONTROL;
            }
            break;

        default:
            ret = ERR_CONTROL;
            break;
    }

    ctx->pc += 4;

    return ret;
}