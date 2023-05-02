#pragma once

#include "bit_macros.h"
#include "error.h"

#define SING_EXT_SIGNED (0)
#define SING_EXT_UNSIGNED (1)

#define SING_EXT_8 (0)
#define SING_EXT_16 (1)
#define SING_EXT_32 (2)

word_t sing_ext(word_t op, word_t width, word_t in, word_t *out)
{
    word_t ret = ERROR_OK;
    word_t pad = 0;

    switch(op) {
        case SING_EXT_SIGNED:
            pad = 0xFFFFFFFF;
            break;

        case SING_EXT_UNSIGNED:
            pad = 0x00000000;
            break;

        default:
            ret = ERROR_SING_EXT;
            break;
    }

    switch(width) {
        case SING_EXT_8:
            *out = (BITS(in ,  0,  7) <<  0) +
                   (BITS(pad,  8, 31) <<  8);
            break;

        case SING_EXT_16:
            *out = (BITS(in ,  0, 15) <<  0) +
                   (BITS(pad, 16, 31) << 16);
            break;

        case SING_EXT_32:
            *out = in; 
            break;

        default:
            ret = ERROR_SING_EXT;
            break;
    }

    return ret;
}
