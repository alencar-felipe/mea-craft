#include "alu.h"

word_t alu(word_t f3, word_t f7, word_t a, word_t b, word_t *c)
{   
    word_t ret = ERR_OK;
    word_t pad = 0;

    /* Support for signed number operations and arithmetical shifts. */

    if(CHK_BIT(f7, 5)) {
        switch(f3) {
            case ALU_F3_ADD:
            case ALU_F3_SLTU:
                TGL_BIT(a, 31);
                TGL_BIT(b, 31);
                break;
            
            case ALU_F3_SL:
            case ALU_F3_SR:
                if(CHK_BIT(a, 31)) {
                    pad = 0xFFFFFFFF;
                }
                break;

            default:
                ret = ERR_ALU;
                break;
        }
    }

    /* Perform operation. */

    switch(f3) {
        case ALU_F3_ADD:
            *c = a + b;
            break;

        case ALU_F3_SL:
            *c = (a << b) + ~(pad << b);
            break;

        case ALU_F3_SLT:
            *c = a < b;
            break;

        case ALU_F3_SLTU:
            *c = a < b;
            break;

        case ALU_F3_XOR:
            *c = a ^ b;
            break;

        case ALU_F3_SR:
            *c = (a >> b) + ~(pad >> b);
            break;

        case ALU_F3_OR:
            *c = a | b;
            break;

        case ALU_F3_AND:
            *c = a & b;
            break;

        default:
            ret = ERR_ALU;
    }

    if(ret) *c = 0;

    return ret;
}