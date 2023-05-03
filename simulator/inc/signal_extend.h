#pragma once

#include "bit_macros.h"
#include "error.h"

#define SIGNAL_EXTEND_SIGNED (0)
#define SIGNAL_EXTEND_UNSIGNED (1)

#define SIGNAL_EXTEND_8 (0)
#define SIGNAL_EXTEND_16 (1)
#define SIGNAL_EXTEND_32 (2)

word_t signal_extend(word_t op, word_t width, word_t in, word_t *out)
{
    word_t ret = ERROR_OK;
    word_t pad = 0;

    switch(op) {
        case SIGNAL_EXTEND_SIGNED:
            pad = 0xFFFFFFFF;
            break;

        case SIGNAL_EXTEND_UNSIGNED:
            pad = 0x00000000;
            break;

        default:
            ret = ERROR_SIGNAL_EXTEND;
            break;
    }

    switch(width) {
        case SIGNAL_EXTEND_8:
            *out = (BITS(in ,  0,  7) <<  0) +
                   (BITS(pad,  8, 31) <<  8);
            break;

        case SIGNAL_EXTEND_16:
            *out = (BITS(in ,  0, 15) <<  0) +
                   (BITS(pad, 16, 31) << 16);
            break;

        case SIGNAL_EXTEND_32:
            *out = in; 
            break;

        default:
            ret = ERROR_SIGNAL_EXTEND;
            break;
    }

    return ret;
}
