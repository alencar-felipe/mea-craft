#include "mylib.h"

int main()
{
    uint32_t c = 0;

    while(1) {
        WRITE_WORD(GPIO_A, c++);
        printf("c: %d\n", (int) c);
        //for(volatile int i = 0; i < 10000; i++);
        //c++;
    }

    return 0;
}