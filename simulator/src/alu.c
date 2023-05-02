#include "alu.h"

word_t alu(word_t op, word_t a, word_t b, word_t *c)
{   
    word_t ret = ERROR_OK;

    if(CHK_BIT(op, 0)) {
        TGL_BIT(a, 31);
        TGL_BIT(b, 31);
    }

    switch(op) {
        case ALU_OR:
            *c = a | b;
            break;

        case ALU_AND:
            *c = a & b;
            break;

        case ALU_XOR:
            *c = a ^ b;
            break;

        case ALU_UNUSED:
            *c = 0;
            break;

        case ALU_ADD:
            *c = a + b;
            break;

        case ALU_SUB:
            *c = a - b;
            break;

        case ALU_LESS_THAN_SIGNED:
        case ALU_LESS_THAN_UNSIGNED:
            *c = a < b;
            break;

        default:
            *c = 0;
            ret = ERR_ALU;
    }

    return ret;
}