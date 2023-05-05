#include "sext.h"

word_t sext(word_t width, word_t in, word_t *out)
{
    word_t ret = ERR_OK;
    word_t pad;

    if(CHK_BIT(in, width - 1)) {
        pad = 0xFFFFFFFF;
    } else {
        pad = 0x00000000;
    }

    switch(width) {
        case SEXT_8:
            *out = (BITS(in ,  0,  7) <<  0) +
                   (BITS(pad,  8, 31) <<  8);
            break;

        case SEXT_12:
            *out = (BITS(in ,  0, 11) <<  0) +
                   (BITS(pad, 12, 31) << 12);
            break;

        case SEXT_16:
            *out = (BITS(in ,  0, 15) <<  0) +
                   (BITS(pad, 16, 31) << 16);
            break;

        case SEXT_20:
            *out = (BITS(in ,  0, 20) <<  0) +
                   (BITS(pad, 21, 31) << 20);
            break;

        case SEXT_32:
            *out = in; 
            break;

        default:
            ret = ERR_SEXT;
            break;
    }

    return ret;
}