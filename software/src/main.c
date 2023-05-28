#include "mylib.h"

int main()
{
    uint32_t c = 0;

    for(int j = 0; j < 64; j++) {
        for(int i = 0; i < 64; i++) {
            uint32_t r = (16 * i) / 64;
            uint32_t g = (16 * j) / 64;
            uint32_t b = (16 * (i+j)) / 128;
            uint32_t color = (r << 8) + (g << 4) + (b << 0);
            WRITE_WORD(0x20000000 + (i + j*64)*4, color);
        }
    }

    while(1) {
        //WRITE_WORD(GPIO_A, 0xFFFFFFFF);
        //WRITE_WORD(0x20000000 + 2*20*4 + 4*c, 0xEEEEEEEE);
        //printf("c: %d\n", (int) c);
        //for(volatile int i = 0; i < 10000; i++);
        c++;
    }

    return 0;
}