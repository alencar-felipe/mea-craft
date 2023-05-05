#include "sign_ext.h"

word_t sign_ext(word_t op, word_t width, word_t in, word_t *out)
{
    word_t ret = ERROR_OK;
    word_t pad = 0;

    switch(op) {
        case SIGN_EXT_SIGNED:
            pad = 0xFFFFFFFF;
            break;

        case SIGN_EXT_UNSIGNED:
            pad = 0x00000000;
            break;

        default:
            ret = ERROR_SIGN_EXT;
            break;
    }

    switch(width) {
        case SIGN_EXT_8:
            *out = (BITS(in ,  0,  7) <<  0) +
                   (BITS(pad,  8, 31) <<  8);
            break;

        case SIGN_EXT_16:
            *out = (BITS(in ,  0, 15) <<  0) +
                   (BITS(pad, 16, 31) << 16);
            break;

        case SIGN_EXT_32:
            *out = in; 
            break;

        default:
            ret = ERROR_SIGN_EXT;
            break;
    }

    return ret;
}