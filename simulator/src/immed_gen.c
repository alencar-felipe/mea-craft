#include "immed_gen.h"

word_t immed_gen(word_t inst, word_t *immed)
{
    word_t res = ERROR_OK;

    word_t opcode = BITS(inst, 0, 6);

    switch(opcode) {

        /* I-type immediate */

        case OPCODE_LOAD:
        case OPCODE_OP_IMMEDIATE:
        case OPCODE_JALR:
            *immed = 
                (BITS(inst, 20, 31) <<  0);
            break;

        /* S-type immediate */

        case OPCODE_STORE:
            *immed =
                (BITS(inst,  7, 11) <<  0) +
                (BITS(inst, 25, 31) <<  5);
            break;

        /* B-type immediate */

        case OPCODE_BRANCH:
            *immed =
                (BITS(inst,  8, 11) <<  1) +
                (BITS(inst, 25, 30) <<  5) +
                (BITS(inst,  7,  7) << 11) +
                (BITS(inst, 31, 31) << 12);
            break;

        /* U-type immediate */

        case OPCODE_LUI:
            *immed = 
                (BITS(inst, 12, 31) <<  0); 
            break;

        /* J-type immediate */

        case OPCODE_JAL:
            *immed =
                (BITS(inst, 12, 19) <<  0) +
                (BITS(inst, 20, 20) <<  8) +
                (BITS(inst, 21, 30) <<  9) +
                (BITS(inst, 31, 31) << 19);
            break;

        default:
            *immed = 0;
            res = ERROR_IMMED_GEN;
    }

    return res;
}