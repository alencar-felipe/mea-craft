#include "mylib.h"

int main()
{
    uint32_t c = 0;

    for(int i = 0; i < 64*64; i++) {
        WRITE_WORD(0x20000000 + i*4, 0xFFF);
    }

    for(int j = 0; j < 32; j++) {
        for(int i = 0; i < 32; i++) {
            WRITE_WORD(0x20000000 + (i + j*64)*4, 0xF0F);
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