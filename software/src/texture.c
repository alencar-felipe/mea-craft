#include "texture.h"

void texture_load(void *dest, void *src)
{
    size_t i = 0;
    size_t j = 32;
    size_t k = 0;

    uint32_t *read_ptr  = (uint32_t *) src;
    uint32_t *write_ptr = (uint32_t *) dest;

    uint32_t read_buf  = 0;
    uint32_t write_buf = 0;

    for(i = 0; i < 3*GPU_TEXT_W*GPU_TEXT_H; i++) {
        if(j >= 32) {
            read_buf = *(read_ptr++);
            j = 0;
        }

        if(k >= 12) {
            *(write_ptr++) = write_buf;
            write_buf = 0;
            k = 0;
        }

        write_buf |= (read_buf & 0xF) << k;
        read_buf = read_buf >> 4;

        j += 4;
        k += 4;
    }
}