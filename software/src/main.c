#include "mylib.h"

int main()
{
    uint32_t c = 0;

    for(int i = 0; i < 40; i++) {
        WRITE_WORD(0x20000000 + i*4, 100);
    }

    while(1) {
        //WRITE_WORD(GPIO_A, 0xFFFFFFFF);
        WRITE_WORD(0x20000000 + 2*20*4 + 4*c, 0xEEEEEEEE);
        printf("c: %d\n", (int) c);
        //for(volatile int i = 0; i < 10000; i++);
        c++;
    }

    return 0;
}